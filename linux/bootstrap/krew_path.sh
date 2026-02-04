# Adds krew path
# _krew_path:
#!/usr/bin/env bash
if ! grep -qF 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' "$HOME/.zshenv"; then
    echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> "$HOME/.zshenv"
    printf "\e[1;33mCHANGED\e[m: Appended krew bin path to .zshenv.\n"
else
    printf "\e[1;32mOK\e[m: ~/.krew/bin path \e[1;32mis already present in .zshenv.\n"
fi