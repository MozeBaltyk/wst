# Installs and sets zsh as default shell and installs oh-my-zsh if needed.
#!/usr/bin/env bash
if command -v zsh >/dev/null 2>&1; then
    omz update >/dev/null 2>&1
    printf "\e[1;34mINFO\e[m: zsh \e[1;32mis already installed and udpated.\n"
else
    printf "\e[1;33mINFO\e[m: zsh is not found. Installing...\n"
    sudo apt install -y zsh
fi
if [[ "$SHELL" = "/usr/bin/zsh" ]]; then
    printf "\e[1;34mINFO\e[m: zsh \e[1;32mis already the default shell.\n"
else
    printf "\e[1;33mINFO\e[m: zsh is not the default shell. Setting as default...\n"
    sudo chsh -s "$(command -v zsh)" $USER
fi
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    printf "\e[1;33mINFO\e[m: Oh-My-Zsh not found. Installing...\n"
    git clone https://github.com/ohmyzsh/ohmyzsh.git "$HOME/.oh-my-zsh"
    if [ -f "$HOME/.zshrc" ]; then
        printf "\e[1;33mINFO\e[m: Moving existing .zshrc to backup...\n"
        mv "$HOME/.zshrc" "$HOME/.zshrc-`date +%Y%m%d%H%M%S`"
    else
        printf "\e[1;33mINFO\e[m: Creating new .zshrc...\n"
        cp "$HOME/.oh-my-zsh/templates/zshrc.zsh-template" "$HOME/.zshrc"
    fi
else
    printf "\e[1;34mINFO\e[m: Oh My Zsh \e[1;32mis already installed.\n"
fi
if grep -q "DISABLE_UPDATE_PROMPT=true" "$HOME/.zshrc"; then
    printf "\e[1;34mINFO\e[m: Automatic omz update \e[1;32mis already disabled.\n"
else
    printf "\e[1;33mINFO\e[m: Disabling automatic omz update at startup...\n"
    echo "export DISABLE_UPDATE_PROMPT=true" >> "$HOME/.zshrc"
fi
printf "\e[1;33mINFO\e[m: Backing up .zshrc...\n"
cp "$HOME/.zshrc" "$HOME/.zshrc-`date +%Y%m%d%H%M%S`"
printf "\e[1;33mINFO\e[m: Cleaning up .zshrc...\n"
sed -i -e '/^#.*$/d' -e '/^$/d' "$HOME/.zshrc"