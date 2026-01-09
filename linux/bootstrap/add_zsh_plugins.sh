# Adds zsh-syntax-highlighting and zsh-autosuggestions plugins if they are not already installed.
#!/usr/bin/env bash
ZSH="$HOME/.oh-my-zsh"
URL="https://github.com/zsh-users/zsh-syntax-highlighting.git"
if [[ ! -d "$ZSH/custom/plugins/zsh-syntax-highlighting" ]]; then
    printf "\e[1;33mINFO\e[m: zsh-syntax-highlighting plugin not found. Adding...\n"
    git clone $URL "$ZSH/custom/plugins/zsh-syntax-highlighting"
else
    printf "\e[1;34mINFO\e[m: zsh-syntax-highlighting \e[1;32mplugin found.\n"
fi
if ! grep -q "zsh-syntax-highlighting" ~/.zshrc; then
    printf "\e[1;33mINFO\e[m: zsh-syntax-highlighting plugin not found in .zshrc. Adding...\n"
    sed -i 's/^plugins=(/plugins=(zsh-syntax-highlighting /' ~/.zshrc
fi
URL="https://github.com/zsh-users/zsh-autosuggestions.git"
if [[ ! -d "$ZSH/custom/plugins/zsh-autosuggestions" ]]; then
    printf "\e[1;33mINFO\e[m: zsh-autosuggestions plugin not found. Adding...\n"
    git clone $URL "$ZSH/custom/plugins/zsh-autosuggestions"
else
    printf "\e[1;34mINFO\e[m: zsh-autosuggestions \e[1;32mplugin found.\n"
fi
if ! grep -q "zsh-autosuggestions" ~/.zshrc; then
    printf "\e[1;33mINFO\e[m: zsh-autosuggestions plugin not found in .zshrc. Adding...\n"
    sed -i 's/^plugins=(/plugins=(zsh-autosuggestions /' ~/.zshrc
fi
sed -i "/^autoload -U compinit; compinit/d" "$HOME/.zshrc"
printf "\e[1;33mINFO\e[m: Appending compinit to .zshrc...\n"
echo "autoload -U compinit; compinit" >> "$HOME/.zshrc."