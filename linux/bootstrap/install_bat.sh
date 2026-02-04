# Installs bat and generates its command completion file.
#!/usr/bin/env bash
ZSH="$HOME/.oh-my-zsh"
#curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -yq >/dev/null 2>&1
#cargo install --locked bat >/dev/null 2>&1

if command -v batcat >/dev/null 2>&1; then
    printf "\e[1;32mOK\e[m: bat command installed successfully as batcat.\n"
else
    sudo apt install -y bat >/dev/null 2>&1
    printf "\e[1;33mCHANGED\e[m: bat command installation successful.\n"
fi

if ! grep -qF "alias bat" "$HOME/.aliases" >/dev/null 2>&1 ; then
    echo "alias bat='batcat --color=always'" >> "$HOME/.aliases"
    printf "\e[1;33mCHANGED\e[m: Appended alias for bat command to .aliases.\n"
else
    printf "\e[1;32mOK\e[m: alias bat \e[1;32mis already present in .aliases.\n"
fi
