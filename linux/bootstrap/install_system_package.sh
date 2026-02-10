#!/usr/bin/env bash

# Installs some Ubuntu packages\

for i in "htop" "tree"; do
    if command -v "$i" >/dev/null 2>&1; then
        printf "\e[1;32mOK\e[m: $i command is already installed.\n"
    else
        sudo apt install -y "$i" >/dev/null 2>&1
        printf "\e[1;33mCHANGED\e[m: $i command installation successful.\n"
    fi
done
