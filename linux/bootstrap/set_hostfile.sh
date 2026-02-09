#!/usr/bin/env bash

ARKADE_BIN="$HOME/.arkade/bin"

# Add for current session
export PATH="$ARKADE_BIN:$PATH"

# Determine shell config
SHELL_RC="$HOME/.zshenv"
if [ -n "$BASH_VERSION" ] || [[ "$SHELL" == */bash ]]; then
    SHELL_RC="$HOME/.bashrc"
fi

# Add permanently if not already there
if ! grep -Fxq 'export PATH="$HOME/.arkade/bin:$PATH"' "$SHELL_RC"; then
    echo 'export PATH="$HOME/.arkade/bin:$PATH"' >> "$SHELL_RC"
    printf "\e[1;33mCHANGED\e[m: Added ~/.arkade/bin to PATH in $SHELL_RC.\n"
else
    printf "\e[1;32mOK\e[m: ~/.arkade/bin already in PATH in $SHELL_RC.\n"
fi