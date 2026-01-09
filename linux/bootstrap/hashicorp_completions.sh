# Checks if the completion lines for packer, terraform, and vault exist in .zshrc and adds them if not.
#!/usr/bin/env bash
ZSH="$HOME/.oh-my-zsh"
ZSHRC="$HOME/.zshrc"
if grep -Fxq "complete -o nospace -C $HOME/.arkade/bin/packer packer" "$ZSHRC"; then
    printf "\e[1;34mINFO\e[m: Packer completion line is present in .zshrc.\n" >/dev/null 2>&1
else
    printf "\e[1;33mINFO\e[m: Packer completion line is missing in .zshrc. Adding it...\n"
    echo "complete -o nospace -C $HOME/.arkade/bin/packer packer" >> "$ZSHRC"
    printf "\e[1;32mINFO\e[m: Packer completion line has been added to .zshrc.\n"
fi
if grep -Fxq "complete -o nospace -C $HOME/.arkade/bin/terraform terraform" "$ZSHRC"; then
    printf "\e[1;34mINFO\e[m: Terraform completion line is present in .zshrc.\n" >/dev/null 2>&1
else
    printf "\e[1;33mINFO\e[m: Terraform completion line is missing in .zshrc. Adding it...\n"
    echo "complete -o nospace -C $HOME/.arkade/bin/terraform terraform" >> "$ZSHRC"
    printf "\e[1;32mINFO\e[m: Terraform completion line has been added to .zshrc.\n"
fi
if grep -Fxq "complete -o nospace -C $HOME/.arkade/bin/vault vault" "$ZSHRC"; then
    printf "\e[1;34mINFO\e[m: Vault completion line is present in .zshrc.\n" >/dev/null 2>&1
else
    printf "\e[1;33mINFO\e[m: Vault completion line is missing in .zshrc. Adding it...\n"
    echo "complete -o nospace -C $HOME/.arkade/bin/vault vault" >> "$ZSHRC"
    printf "\e[1;32mINFO\e[m: Vault completion line has been added to .zshrc.\n"
fi