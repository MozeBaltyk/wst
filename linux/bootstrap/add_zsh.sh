#!/usr/bin/env bash

# Installs and sets zsh as default shell and installs oh-my-zsh if needed.
if command -v zsh >/dev/null 2>&1; then
    omz update >/dev/null 2>&1
    printf "\e[1;32mOK\e[m: zsh \e[1;32mis already installed and udpated.\n"
else
    sudo apt install -y zsh
    printf "\e[1;33mCHANGED\e[m: zsh is not found. Installing...\n"
fi
if [[ "$SHELL" = "/usr/bin/zsh" ]]; then
    printf "\e[1;32mOK\e[m: zsh \e[1;32mis already the default shell.\n"
else
    sudo chsh -s "$(command -v zsh)" $USER
    printf "\e[1;33mCHANGED\e[m: zsh set as the default shell.\n"
fi
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
    printf "\e[1;33mCHANGED\e[m: Oh-My-Zsh installed to $HOME/.oh-my-zsh\n"
    if [ -f "$HOME/.zshrc" ]; then
        printf "\e[1;34mINFO\e[m: Moving existing .zshrc to backup...\n"
        mv "$HOME/.zshrc" "$HOME/.zshrc-`date +%Y%m%d%H%M%S`"
    else
        cp "$HOME/.oh-my-zsh/templates/zshrc.zsh-template" "$HOME/.zshrc"
        printf "\e[1;33mCHANGED\e[m: Created new .zshrc from template.\n"
    fi
else
    printf "\e[1;32mOK\e[m: Oh My Zsh \e[1;32mis already installed.\n"
fi
if grep -q "DISABLE_UPDATE_PROMPT=true" "$HOME/.zshrc"; then
    printf "\e[1;32mOK\e[m: Automatic omz update \e[1;32mis already disabled.\n"
else
    echo "export DISABLE_UPDATE_PROMPT=true" >> "$HOME/.zshrc"
    printf "\e[1;33mCHANGED\e[m: Disabled automatic omz update at startup...\n"
fi
ZSHRC_BACKUP="$HOME/.zshrc-`date +%Y%m%d%H%M%S`"
cp "$HOME/.zshrc" "$ZSHRC_BACKUP"
printf "\e[1;33mCHANGED\e[m: Backed up .zshrc to $ZSHRC_BACKUP\n"
sed -i -e '/^#.*$/d' -e '/^$/d' "$HOME/.zshrc"
printf "\e[1;33mCHANGED\e[m: Cleaned up .zshrc...\n"