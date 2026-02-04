#!/usr/bin/env bash
set -euo pipefail

# Colors
BLUE="\e[1;34m"
YELLOW="\e[1;33m"
GREEN="\e[1;32m"
RED="\e[1;31m"
RESET="\e[m"

# Helper: print colored info
info() {
  echo -e "${BLUE}INFO:${RESET} $1"
}
warn() {
  echo -e "${YELLOW}WARN:${RESET} $1"
}
changed() {
  echo -e "${YELLOW}CHANGED:${RESET} $1"
}
ok() {
  echo -e "${GREEN}OK:${RESET} $1"
}
error() {
  echo -e "${RED}ERROR:${RESET} $1"
}

# --- jq is required for this script ---
if ! command -v jq >/dev/null 2>&1; then
  arkade get jq --quiet
fi

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
    ok "Neovim $CURRENT_VERSION is already up-to-date."
    exit 0
  fi
  info "A newer Neovim version $LATEST_VERSION is available. Updating..."
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

changed "Neovim has been installed/updated to version $LATEST_VERSION."

# --- Shell config updates ---
# 1) Aliases: v->nvim, vi->nvim, vim->nvim
ZSHRC="$HOME/.zshrc"
ZSHENV="$HOME/.zshenv"
ALIAS_FILE="$HOME/.aliases"
if ! grep -qF "alias v='nvim'" "$ALIAS_FILE"; then
  echo "alias v='nvim'" >> "$ALIAS_FILE"
  changed "Added alias v='nvim' to .aliases..."
fi
if ! grep -qF "alias vi='nvim'" "$ALIAS_FILE"; then
  echo "alias vi='nvim'" >> "$ALIAS_FILE"
  changed "Added alias vi='nvim' to .aliases..."
fi
if ! grep -qF "alias vim='nvim'" "$ALIAS_FILE"; then
  echo "alias vim='nvim'" >> "$ALIAS_FILE"
  changed "Added alias vim='nvim' to .aliases..."
fi
if ! grep -qF "source $ALIAS_FILE" "$ZSHRC"; then
  echo "source $ALIAS_FILE" >> "$ZSHRC"
  changed "Sourced .aliases in .zshrc..."
fi

# 2) Default EDITOR and VISUAL and MANPAGER to nvim
if ! grep -q 'export PATH=$PATH:/usr/local/bin/nvim/bin' "$ZSHENV"; then
  echo 'export PATH=$PATH:/usr/local/bin/nvim/bin' >> "$ZSHENV"
  changed "Added Neovim to PATH in .zshenv..."
fi
if ! grep -q 'export EDITOR=nvim' "$ZSHENV"; then
  if grep -q '^export EDITOR=' "$ZSHENV"; then
    sed -i 's|^export EDITOR=.*|export EDITOR=nvim|' "$ZSHENV"
    changed "Made Neovim the default editor in .zshenv..."
  else
    echo 'export EDITOR=nvim' >> "$ZSHENV"
    changed "Made Neovim the default editor in .zshenv..."
  fi
fi
if ! grep -q 'export VISUAL=nvim' "$ZSHENV"; then
  if grep -q '^export VISUAL=' "$ZSHENV"; then
    sed -i 's|^export VISUAL=.*|export VISUAL=nvim|' "$ZSHENV"
    changed "Made Neovim the default visual editor in .zshenv..."
  else
    echo 'export VISUAL=nvim' >> "$ZSHENV"
    changed "Made Neovim the default visual editor in .zshenv..."
  fi
fi
if ! grep -q 'export MANPAGER=' "$ZSHENV"; then
  if grep -q '^export MANPAGER=' "$ZSHENV"; then
    sed -i "s|^export MANPAGER=.*|export MANPAGER='nvim +Man!'|" "$ZSHENV"
    changed "Set Neovim as the default manpager in .zshenv..."
  else
    echo "export MANPAGER='nvim +Man!'" >> "$ZSHENV"
    changed "Set Neovim as the default manpager in .zshenv..."
  fi
fi

# --- Install vim-plug if needed ---  
if [[ ! -f "$HOME/.config/nvim/autoload/plug.vim" ]]; then
  curl -sfLo "$HOME/.config/nvim/autoload/plug.vim" --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  changed "vim-plug installed."
else
  ok "vim-plug is already installed."
fi

# --- Ensure init.vim has basic plug#begin / plug#end ---
NVIM_INIT="$HOME/.config/nvim/init.vim"
SEARCH_STRING="call plug#begin('~/.config/nvim/plugged')"
if [[ -f "$NVIM_INIT" ]]; then
  if ! grep -q "$SEARCH_STRING" "$NVIM_INIT"; then
    echo -e "\ncall plug#begin('~/.config/nvim/plugged')" >> "$NVIM_INIT"
    echo "call plug#end()" >> "$NVIM_INIT"
    changed "Added vim-plug setup to init.vim."
  else
    ok "init.vim already has vim-plug setup."
  fi
else
  mkdir -p "$(dirname "$NVIM_INIT")"
  echo "call plug#begin('~/.config/nvim/plugged')" >  "$NVIM_INIT"
  echo "call plug#end()"                          >> "$NVIM_INIT"
  changed "Created init.vim with vim-plug setup."
fi

# --- Disable mouse mode in Neovim ---
if ! grep -qE '^set mouse=' "$NVIM_INIT"; then
  echo "set mouse=" >> "$NVIM_INIT"
  changed "Disabled mouse mode in Neovim."
fi

# info "Done. Please open a new shell or source your .zshrc to finalize changes."
