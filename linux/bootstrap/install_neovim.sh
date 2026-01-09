#!/usr/bin/env bash
set -euo pipefail

# Colors for info messages
CYAN="\e[1;34mINFO\e[m:"
YELLOW="\e[1;33mINFO\e[m:"
GREEN="\e[1;32m"
RESET="\e[m"

# Helper: print colored info
info() {
  echo -e "${CYAN} $1"
}
warn() {
  echo -e "${YELLOW} $1"
}

# --- Get current & latest versions ---
if command -v nvim >/dev/null 2>&1; then
  CURRENT_VERSION="$(nvim --version | grep 'NVIM' | grep -o '[0-9.]*' | head -n1)"
else
  CURRENT_VERSION="0"
fi

LATEST_VERSION_URL="https://api.github.com/repos/neovim/neovim/tags"
LATEST_VERSION="$(curl -s "$LATEST_VERSION_URL" | jq -r '.[0].name' | sed 's/^v//')"

# --- Decide if fresh install or update ---
if ! command -v nvim >/dev/null 2>&1; then
  warn "Neovim not found. Installing..."
  # Pull stable release
  NVIM_URL="https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz"
else
  info "Neovim is installed at: $(which nvim) (version $CURRENT_VERSION)"
  info "Checking for updates (latest version: $LATEST_VERSION)..."
  if [[ "$CURRENT_VERSION" == "$LATEST_VERSION" ]]; then
    info "Neovim $CURRENT_VERSION is already up-to-date."
    exit 0
  fi
  warn "A newer Neovim version $LATEST_VERSION is available. Updating..."
  NVIM_URL="https://github.com/neovim/neovim/releases/download/stable/nvim-linux-x86_64.tar.gz"
fi

# --- Download and extract into a temp folder ---
rm -rf /tmp/nvim-linux-x86_64
mkdir -p /tmp/nvim-linux-x86_64
pushd /tmp/nvim-linux-x86_64 >/dev/null

curl -sLO "$NVIM_URL"

# If it's truly a .tar.gz, include `-z`. If GitHub is shipping a plain tar, remove `-z`.
tar -xzf nvim-linux-x86_64.tar.gz --strip-components=1
rm -f nvim-linux-x86_64.tar.gz

popd >/dev/null

# --- Move to /usr/local/nvim and symlink ---
sudo rm -rf /usr/local/nvim   # remove any old version
sudo mv /tmp/nvim-linux-x86_64 /usr/local/nvim
sudo chmod -R 755 /usr/local/nvim

# Replace or create the symlink so `nvim` is on PATH
sudo ln -sf /usr/local/nvim/bin/nvim /usr/local/bin/nvim

info "Neovim has been installed/updated to version $LATEST_VERSION."

# --- Shell config updates ---
# 1) Aliases: vi->nvim, vim->nvim
ZSHRC="$HOME/.zshrc"
if ! grep -qF "alias vi='nvim'" "$ZSHRC"; then
  warn "Adding alias vi='nvim' to .zshrc..."
  echo "alias vi='nvim'" >> "$ZSHRC"
fi
if ! grep -qF "alias vim='nvim'" "$ZSHRC"; then
  warn "Adding alias vim='nvim' to .zshrc..."
  echo "alias vim='nvim'" >> "$ZSHRC"
fi

# 2) Default EDITOR
# If you want the entire path:
#    EDITOR="/usr/local/nvim/bin/nvim"
# but now that /usr/local/bin/nvim is a symlink, we can just do /usr/local/bin/nvim
if ! grep -q 'export EDITOR="/usr/local/bin/nvim"' "$ZSHRC"; then
  warn "Making Neovim the default editor in .zshrc..."
  if grep -q '^export EDITOR=' "$ZSHRC"; then
    sed -i 's|^export EDITOR=.*|export EDITOR="/usr/local/bin/nvim"|' "$ZSHRC"
  else
    echo 'export EDITOR="/usr/local/bin/nvim"' >> "$ZSHRC"
  fi
fi

# 3) PATH updates (not strictly necessary if we use the symlink above)
# If you do want /usr/local/nvim/bin in your PATH:
# if ! grep -qF 'export PATH=$PATH:/usr/local/nvim/bin' "$ZSHRC"; then
#   echo 'export PATH=$PATH:/usr/local/nvim/bin' >> "$ZSHRC"
# fi

# --- Install vim-plug if needed ---  
if [[ ! -f "$HOME/.config/nvim/autoload/plug.vim" ]]; then
  warn "vim-plug not found. Installing..."
  curl -sfLo "$HOME/.config/nvim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  info "vim-plug installed."
else
  info "vim-plug is already installed."
fi

# --- Ensure init.vim has basic plug#begin / plug#end ---
NVIM_INIT="$HOME/.config/nvim/init.vim"
SEARCH_STRING="call plug#begin('~/.config/nvim/plugged')"
if [[ -f "$NVIM_INIT" ]]; then
  if ! grep -q "$SEARCH_STRING" "$NVIM_INIT"; then
    warn "Adding basic vim-plug setup to init.vim..."
    echo -e "\ncall plug#begin('~/.config/nvim/plugged')" >> "$NVIM_INIT"
    echo "call plug#end()" >> "$NVIM_INIT"
  else
    info "init.vim already has vim-plug setup."
  fi
else
  warn "init.vim not found. Creating it with vim-plug setup..."
  mkdir -p "$(dirname "$NVIM_INIT")"
  echo "call plug#begin('~/.config/nvim/plugged')" >  "$NVIM_INIT"
  echo "call plug#end()"                          >> "$NVIM_INIT"
fi

# --- Disable mouse mode in Neovim ---
if ! grep -qE '^set mouse=' "$NVIM_INIT"; then
  warn "Disabling mouse mode in Neovim..."
  echo "set mouse=" >> "$NVIM_INIT"
fi

# info "Done. Please open a new shell or source your .zshrc to finalize changes."
 
 if ! grep -qF "alias inv=" "$HOME/.zshrc"; then
        printf "\e[1;33mINFO\e[m: Adding inv as an alias to vim...\n"
        echo "alias inv='nvim \$(fzf -m --preview=\"batcat --color=always {}\")'" >> "$HOME/.zshrc"
    else
        printf "\e[1;34mINFO\e[m: inv alias for neovim and fzf \e[1;32mis already present in .zshrc.\n"
    fi
