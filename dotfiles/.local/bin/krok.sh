#!/usr/bin/env bash
# Create a kubeconfig with namespace-scoped "view" + pods/portforward access.
# Usage: ./create-readonly-portforward-kubeconfig.sh [-o FILE] [-d DURATION] [--force] NAMESPACE [NAMESPACE...]
set -Eeuo pipefail
umask 077

SA_NAME="readonly-portforward-user"
PF_ROLE="readonly-portforward-role"
# Keep our binding separate from the manually created `readonly-view-binding`.
# Reusing that name would overwrite its subjects and could revoke another SA's access.
VIEW_BINDING="readonly-portforward-user-view-binding"
# Dedicated binding name: do not collide with pre-existing manually created
# readonly-portforward-binding (which may reference a different immutable roleRef).
PF_BINDING="readonly-portforward-user-pf-binding"
OUTPUT="./readonly-portforward.kubeconfig"
ADMIN_KUBECONFIG=""
DURATION="24h"
FORCE=false
NAMESPACES=()

usage() {
  cat <<'HELP'
Usage: create-readonly-portforward-kubeconfig.sh [options] NAMESPACE [NAMESPACE...]

Options:
  -o, --output FILE       Output kubeconfig (default: ./readonly-portforward.kubeconfig)
  -k, --admin-kubeconfig FILE  Explicit source/admin kubeconfig (optional)
  -d, --duration DURATION Requested token lifetime (default: 24h; e.g. 24h, 7d, 1w)
      --force             Replace an existing output file
  -h, --help              Show help

The CURRENT kubectl context must have permission to manage ServiceAccounts,
Roles, and RoleBindings in the requested namespaces and to create SA tokens.
The ServiceAccount lives in the FIRST namespace; RoleBindings grant it access
in each requested namespace. Existing RBAC grants are not removed.

Durations accept a positive integer followed by s (seconds), m (minutes),
h (hours), d (days), or w (weeks). Days/weeks are converted to hours
before passing --duration to kubectl (e.g. 7d -> 168h). The API server
may issue a token with a different expiration time.
HELP
}

die() { printf 'ERROR: %s\n' "$*" >&2; exit 1; }

while (($#)); do
  case "$1" in
    -o|--output)
      (($# >= 2)) || die "$1 requires a file path"
      OUTPUT=$2; shift 2 ;;
    -k|--admin-kubeconfig)
      (($# >= 2)) || die "$1 requires a file path"
      ADMIN_KUBECONFIG=$2; shift 2 ;;
    -d|--duration)
      (($# >= 2)) || die "$1 requires a duration"
      DURATION=$2; shift 2 ;;
    --force) FORCE=true; shift ;;
    -h|--help) usage; exit 0 ;;
    --) shift; while (($#)); do NAMESPACES+=("$1"); shift; done ;;
    -*) die "unknown option: $1" ;;
    *) NAMESPACES+=("$1"); shift ;;
  esac
done

((${#NAMESPACES[@]} > 0)) || { usage >&2; die "supply at least one namespace"; }
command -v kubectl >/dev/null || die "kubectl is not installed"
if [[ -n "$ADMIN_KUBECONFIG" ]]; then
  [[ -f "$ADMIN_KUBECONFIG" && -r "$ADMIN_KUBECONFIG" ]] \
    || die "admin kubeconfig not found or unreadable: $ADMIN_KUBECONFIG"
  # Only this process (and its kubectl subprocesses) uses the chosen config.
  export KUBECONFIG="$ADMIN_KUBECONFIG"
fi
# kubectl uses Go durations (e.g. 24h), which do not accept d or w.
# Translate user-friendly days/weeks to hours. Validate early, before
# creating any RBAC resources. Limit input length to avoid Bash overflow.
normalize_duration() {
  local raw=$1 count unit
  if [[ ! "$raw" =~ ^([1-9][0-9]{0,7})([smhdw])$ ]]; then
    die "invalid duration '$raw' (use a positive integer and s/m/h/d/w, e.g. 24h or 7d)"
  fi
  count=$((10#${BASH_REMATCH[1]}))
  unit=${BASH_REMATCH[2]}
  case "$unit" in
    d) printf '%sh' "$((count * 24))" ;;
    w) printf '%sh' "$((count * 168))" ;;
    *) printf '%s%s' "$count" "$unit" ;;
  esac
}
KUBECTL_DURATION=$(normalize_duration "$DURATION")
[[ -n "$OUTPUT" && "$OUTPUT" != */ ]] || die "invalid output path"
[[ -d "$(dirname -- "$OUTPUT")" ]] || die "output directory does not exist"
[[ ! -e "$OUTPUT" || "$FORCE" == true ]] || die "output already exists; use --force to replace it"

# Avoid accidentally replacing the admin kubeconfig if the paths match.
if [[ -n "${KUBECONFIG:-}" && "$OUTPUT" == "$KUBECONFIG" ]]; then
  die "output must differ from the admin KUBECONFIG"
fi

# Check names, remove duplicates (keeps the original order).
UNIQUE=()
for ns in "${NAMESPACES[@]}"; do
  [[ ${#ns} -le 63 && "$ns" =~ ^[a-z0-9]([-a-z0-9]*[a-z0-9])?$ ]] \
    || die "invalid Kubernetes namespace name: $ns"
  seen=false
  for prev in "${UNIQUE[@]}"; do
    if [[ "$prev" == "$ns" ]]; then seen=true; break; fi
  done
  [[ "$seen" == true ]] || UNIQUE+=("$ns")
done
NAMESPACES=("${UNIQUE[@]}")
HOME_NS="${NAMESPACES[0]}"

ADMIN_CONTEXT=$(kubectl config current-context) || die "cannot read active admin context"
printf 'Admin context: %s\nSA home namespace: %s\nTarget namespaces: %s\n' \
  "$ADMIN_CONTEXT" "$HOME_NS" "${NAMESPACES[*]}"
printf 'Requested token duration: %s (kubectl: %s)\n' "$DURATION" "$KUBECTL_DURATION"
printf 'Planned output kubeconfig: %s (created after RBAC setup)\n' "$OUTPUT"

# Preflight: distinguish TLS/connection failures from missing namespaces.
# Show kubectl's real error; the old generic message could misdiagnose TLS errors.
for ns in "${NAMESPACES[@]}"; do
  if ! namespace_result=$(kubectl get namespace "$ns" -o name 2>&1); then
    printf '%s\n' "$namespace_result" >&2
    case "$namespace_result" in
      *'certificate signed by unknown authority'*|*'tls: failed to verify certificate'*)
        die "TLS verification failed with admin context '$ADMIN_CONTEXT'. Check the source kubeconfig's API endpoint and certificate authority; if needed pass --admin-kubeconfig FILE. Do not disable TLS verification."
        ;;
      *'(NotFound)'*|*'not found'*)
        die "namespace does not exist: $ns"
        ;;
      *'(Forbidden)'*|*'forbidden'*)
        die "admin credentials cannot read namespace: $ns"
        ;;
      *)
        die "could not query namespace '$ns' using admin context '$ADMIN_CONTEXT' (see kubectl error above)"
        ;;
    esac
  fi
done

# Preserve the API server endpoint and CA from the current administrator context.
# --flatten embeds a file-based CA certificate when the source uses one.
SERVER=$(kubectl config view --raw --flatten --minify \
  -o jsonpath='{.clusters[0].cluster.server}')
CA_DATA=$(kubectl config view --raw --flatten --minify \
  -o jsonpath='{.clusters[0].cluster.certificate-authority-data}')
TLS_NAME=$(kubectl config view --raw --flatten --minify \
  -o jsonpath='{.clusters[0].cluster.tls-server-name}')
INSECURE=$(kubectl config view --raw --flatten --minify \
  -o jsonpath='{.clusters[0].cluster.insecure-skip-tls-verify}')
[[ "$SERVER" == https://* ]] || die "expected an HTTPS Kubernetes API server URL"
[[ "$INSECURE" != true ]] || die "refusing to generate a kubeconfig with TLS verification disabled"

# A dedicated ServiceAccount is shared across the namespaces via RoleBindings.
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: ${SA_NAME}
  namespace: ${HOME_NS}
automountServiceAccountToken: false
EOF

for ns in "${NAMESPACES[@]}"; do
  cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: ${PF_ROLE}
  namespace: ${ns}
rules:
- apiGroups: [""]
  resources: ["pods/portforward"]
  verbs: ["create"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ${VIEW_BINDING}
  namespace: ${ns}
subjects:
- kind: ServiceAccount
  name: ${SA_NAME}
  namespace: ${HOME_NS}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: view
---
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: ${PF_BINDING}
  namespace: ${ns}
subjects:
- kind: ServiceAccount
  name: ${SA_NAME}
  namespace: ${HOME_NS}
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: ${PF_ROLE}
EOF
done

TOKEN=$(kubectl -n "$HOME_NS" create token "$SA_NAME" --duration="$KUBECTL_DURATION")
[[ -n "$TOKEN" ]] || die "API server returned an empty ServiceAccount token"

# Atomically write the output and never expose the token in command-line arguments.
TMP=$(mktemp "${OUTPUT}.tmp.XXXXXX")
trap 'rm -f -- "${TMP:-}"; unset TOKEN' EXIT
{
  cat <<EOF
apiVersion: v1
kind: Config
clusters:
- name: restricted-cluster
  cluster:
    server: ${SERVER}
EOF
  if [[ -n "$CA_DATA" ]]; then
    printf '    certificate-authority-data: %s\n' "$CA_DATA"
  fi
  if [[ -n "$TLS_NAME" ]]; then
    printf '    tls-server-name: %s\n' "$TLS_NAME"
  fi
  cat <<EOF
users:
- name: ${SA_NAME}
  user:
    token: ${TOKEN}
contexts:
EOF
  for ns in "${NAMESPACES[@]}"; do
    cat <<EOF
- name: readonly-${ns}
  context:
    cluster: restricted-cluster
    user: ${SA_NAME}
    namespace: ${ns}
EOF
  done
  printf 'current-context: readonly-%s\n' "$HOME_NS"
} > "$TMP"
chmod 600 "$TMP"
kubectl --kubeconfig="$TMP" config current-context >/dev/null \
  || die "generated kubeconfig failed syntax validation"
mv -f -- "$TMP" "$OUTPUT"
unset TOKEN
printf '\nKubeconfig written: %s (mode 600)\n' "$OUTPUT"

# ---------- Checks: use ONLY the newly generated, restricted kubeconfig ----------
printf '\n=== Kubeconfig checks ===\n'
failures=0
check_can_i() {
  local ns=$1 expectation=$2 description=$3
  shift 3
  local result status
  if result=$(kubectl --kubeconfig="$OUTPUT" auth can-i "$@" -n "$ns" 2>&1); then
    status=0
  else
    status=$?
  fi
  # kubectl auth can-i prints "no" and exits 1 for a denied permission.
  if [[ "$result" == "$expectation" ]] && \
     { [[ "$status" -eq 0 ]] || [[ "$status" -eq 1 && "$result" == no ]]; }; then
    printf '[PASS] %-26s %-32s %s\n' "$ns" "$description" "$result"
  else
    printf '[FAIL] %-26s %-32s expected %s, got %s (exit %s)\n' \
      "$ns" "$description" "$expectation" "$result" "$status"
    failures=$((failures + 1))
  fi
}

for ns in "${NAMESPACES[@]}"; do
  check_can_i "$ns" yes 'list pods' list pods
  check_can_i "$ns" yes 'create pods/portforward' create pods --subresource=portforward
  check_can_i "$ns" no  'create pods' create pods
  check_can_i "$ns" no  'delete pods' delete pods
  check_can_i "$ns" no  'get secrets' get secrets
  if kubectl --kubeconfig="$OUTPUT" -n "$ns" get pods >/dev/null; then
    printf '[PASS] %-26s %-32s success\n' "$ns" 'live get pods'
  else
    printf '[FAIL] %-26s %-32s failed\n' "$ns" 'live get pods'
    failures=$((failures + 1))
  fi
done

# Check a namespace not in the requested scope. If it does not exist,
# SubjectAccessReview (kubectl auth can-i) can still evaluate access there.
OUTSIDE=""
for candidate in default kube-system kube-public kube-node-lease; do
  is_target=false
  for ns in "${NAMESPACES[@]}"; do
    if [[ "$ns" == "$candidate" ]]; then is_target=true; break; fi
  done
  if [[ "$is_target" == false ]]; then OUTSIDE="$candidate"; break; fi
done
if [[ -n "$OUTSIDE" ]]; then
  check_can_i "$OUTSIDE" no 'list pods (outside scope)' list pods
fi

printf '\nExample: kubectl --kubeconfig=%q --context=readonly-%s -n %s port-forward svc/YOUR_SERVICE 8080:8080\n' \
  "$OUTPUT" "$HOME_NS" "$HOME_NS"
if ((failures > 0)); then
  printf '\n%d check(s) failed; inspect existing RBAC or token authentication.\n' "$failures" >&2
  exit 1
fi
printf '\nAll checks passed.\n'

