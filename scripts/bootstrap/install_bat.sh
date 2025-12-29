# Installs bat and generates its command completion file.
#!/usr/bin/env bash
ZSH="$HOME/.oh-my-zsh"
#curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -yq >/dev/null 2>&1
#cargo install --locked bat >/dev/null 2>&1
printf "\e[1;33mINFO\e[m: installing bat command...\n"
sudo apt install -y bat >/dev/null 2>&1
if ! grep -qF "alias bat" "$HOME/.zshrc"; then
    printf "\e[1;33mINFO\e[m: Appending alias for bat command to .zshrc...\n"
    echo "alias bat='bat --color=always'" >> "$HOME/.zshrc"
else
    printf "\e[1;34mINFO\e[m: alias bat \e[1;32mis already present in .zshrc.\n"
fi
if ! grep -qF "BAT_THEME" "$HOME/.zshrc"; then
    printf "\e[1;33mINFO\e[m: Adding bat theme to .zshrc...\n"
    echo "export BAT_THEME='TwoDark'" >> "$HOME/.zshrc"
else
    printf "\e[1;34mINFO\e[m: bat theme \e[1;32mis already present in .zshrc.\n"
fi

