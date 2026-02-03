# Adds krew path
# _krew_path:
#!/usr/bin/env bash
if ! grep -qF 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' "$HOME/.zshenv"; then
    printf "\e[1;33mCHANGED\e[m: Appending krew bin path to .zshenv...\n"
    echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> "$HOME/.zshenv"
else
    printf "\e[1;32mOK\e[m: ~/.krew/bin path \e[1;32mis already present in .zshenv.\n"
fi