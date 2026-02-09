#!/usr/bin/env bash

# Installs ripgrep and generates its command completion file.

ZSH="$HOME/.oh-my-zsh"

sudo apt install -y ripgrep >/dev/null 2>&1
mkdir -p $ZSH/completions
if [[ -s "$ZSH/completions/_rg" ]]; then
    printf "\e[1;32mOK\e[m: rg completion already exists.\n" >/dev/null 2>&1
else
    url="https://raw.githubusercontent.com/BurntSushi/ripgrep/master/complete/_rg"
    curl $url > "$ZSH/completions/_rg"
    printf "\e[1;33mCHANGED\e[m: Generated command completion file _rg...\n"
fi