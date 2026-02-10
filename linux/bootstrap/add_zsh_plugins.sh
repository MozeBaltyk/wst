#!/usr/bin/env bash

ZSH="$HOME/.oh-my-zsh"
# --- zsh-syntax-highlighting ---
URL="https://github.com/zsh-users/zsh-syntax-highlighting.git"
if [[ ! -d "$ZSH/custom/plugins/zsh-syntax-highlighting" ]]; then
    git clone $URL "$ZSH/custom/plugins/zsh-syntax-highlighting"
    printf "\e[1;33mCHANGED\e[m: zsh-syntax-highlighting plugin installed.\n"
else
    printf "\e[1;34mINFO\e[m: zsh-syntax-highlighting \e[1;32mplugin found.\n"
fi
if ! grep -q "zsh-syntax-highlighting" ~/.zshrc; then
    sed -i 's/^plugins=(/plugins=(zsh-syntax-highlighting /' ~/.zshrc
    printf "\e[1;33mCHANGED\e[m: zsh-syntax-highlighting plugin added to .zshrc.\n"
fi
# --- zsh-autosuggestions ---
URL="https://github.com/zsh-users/zsh-autosuggestions.git"
if [[ ! -d "$ZSH/custom/plugins/zsh-autosuggestions" ]]; then
    git clone $URL "$ZSH/custom/plugins/zsh-autosuggestions"
    printf "\e[1;33mCHANGED\e[m: zsh-autosuggestions plugin installed.\n"
else
    printf "\e[1;34mINFO\e[m: zsh-autosuggestions \e[1;32mplugin found.\n"
fi
if ! grep -q "zsh-autosuggestions" ~/.zshrc; then
    sed -i 's/^plugins=(/plugins=(zsh-autosuggestions /' ~/.zshrc
    printf "\e[1;33mCHANGED\e[m: zsh-autosuggestions plugin added to .zshrc.\n"

fi
# --- Ensure compinit is called ---
if ! grep -q "compinit" ~/.zshrc; then
    echo "autoload -U compinit; compinit" >> "$HOME/.zshrc"
    printf "\e[1;33mCHANGED\e[m: compinit is not called in .zshrc. Adding it...\n"
fi