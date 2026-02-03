#!/usr/bin/env bash
ZSH="$HOME/.oh-my-zsh"
if command -v just >/dev/null 2>&1; then
    printf "\e[1;32mOK\e[m: just \e[1;32mis already installed.\n"
else
    if [ -f ~/.arkade/bin/just ]; then
        printf "\e[1;33mCHANGED\e[m: just is not found. Installing...\n"
        arkade get just
    else
        printf "\e[1;31mERROR\e[m: arkade is not installed. Please install arkade first.\n"
    fi
fi

# Generate just completions
mkdir -p $ZSH/completions
if [[ -s "$ZSH/completions/_just" ]]; then
    printf "\e[1;32mOK\e[m: just completion already exists.\n" >/dev/null 2>&1
else
    printf "\e[1;33mCHANGED\e[m: Generating command completion file _just...\n"
    just --completions zsh > "$ZSH/completions/_just"
fi


