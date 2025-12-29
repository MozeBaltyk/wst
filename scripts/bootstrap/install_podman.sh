# Installs podman and generates its command completion file.
#!/usr/bin/env bash
ZSH="$HOME/.oh-my-zsh"
sudo apt install -y podman cockpit cockpit-podman >/dev/null 2>&1
mkdir -p $ZSH/completions
if [[ -s "$ZSH/completions/_podman" ]]; then
    printf "\e[1;34mINFO\e[m: podman completion already exists.\n" >/dev/null 2>&1
else
    printf "\e[1;33mINFO\e[m: Generating command completion file _podman...\n"
    podman completion zsh > "$ZSH/completions/_podman"
fi