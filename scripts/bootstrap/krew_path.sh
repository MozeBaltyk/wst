# Adds krew path
# _krew_path:
#!/usr/bin/env bash
if ! grep -qF 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' "$HOME/.zshrc"; then
    printf "\e[1;33mINFO\e[m: Appending krew bin path to .zshrc...\n"
    echo 'export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"' >> "$HOME/.zshrc"
else
    printf "\e[1;34mINFO\e[m: ~/.krew/bin path \e[1;32mis already present in .zshrc.\n"
fi