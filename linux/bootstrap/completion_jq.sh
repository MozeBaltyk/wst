#!/usr/bin/env bash
ZSH="$HOME/.oh-my-zsh"
ZSHRC="$HOME/.zshrc"

# jq completion
if grep -Fxq "compdef _gnu_generic jq" "$ZSHRC"; then
    printf "\e[1;32mOK\e[m: Jq completion line is present in .zshrc.\n" >/dev/null 2>&1
else
    echo "compdef _gnu_generic jq" >> "$ZSHRC"
    printf "\e[1;33mCHANGED\e[m: Jq completion line has been added to .zshrc.\n"
fi