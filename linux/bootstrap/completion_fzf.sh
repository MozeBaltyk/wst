#!/usr/bin/env bash

# A similar function to _install, but doesn't generate command completion file.
export PATH="$PATH:$HOME/.arkade/bin:/usr/local/bin"

if [ -z "$1" ]; then
  printf "\e[1;31mERROR\e[m: No tool name provided."
  exit 1
fi

TOOL="$1"

# Check if tool is already installed
if command -v "$TOOL" >/dev/null 2>&1; then
  printf "\e[1;32mOK\e[m: %s \e[1;32mis already installed.\n" "$TOOL"
  exit 0
fi

# Check if arkade is installed
if ! command -v arkade >/dev/null 2>&1; then
  printf "\e[1;31mERROR\e[m: arkade is not installed or not in PATH. Please install arkade first.\n"
  exit 1
fi

# Install the tool
printf "\e[1;33mCHANGED\e[m: %s not found. Installing with arkade...\n" "$TOOL"
arkade get "$TOOL" --quiet