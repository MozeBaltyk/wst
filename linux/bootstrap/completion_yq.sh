#!/usr/bin/env bash

# Adds command completion for yq.
ZSH="$HOME/.oh-my-zsh"
mkdir -p $ZSH/completions
if [[ -s "$ZSH/completions/_yq" ]]; then
    printf "\e[1;32mOK\e[m: yq completion already exists.\n" >/dev/null 2>&1
else
    yq shell-completion zsh > "$ZSH/completions/_yq"
    printf "\e[1;33mCHANGED\e[m: Generated command completion file _yq.\n"
fi