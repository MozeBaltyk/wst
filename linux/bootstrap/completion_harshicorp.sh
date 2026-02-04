# Checks if the completion lines for harshicorp-like tools exist in .zshrc and adds them if not.
#!/usr/bin/env bash
ZSH="$HOME/.oh-my-zsh"
ZSHRC="$HOME/.zshrc"

# Tofu completion
if grep -Fxq "complete -o nospace -C $HOME/.arkade/bin/tofu tofu" "$ZSHRC"; then
    printf "\e[1;32mOK\e[m: Tofu completion line is present in .zshrc.\n" >/dev/null 2>&1
else
    echo "complete -o nospace -C $HOME/.arkade/bin/tofu tofu" >> "$ZSHRC"
    printf "\e[1;33mCHANGED\e[m: Tofu completion line has been added to .zshrc.\n"
fi

# Vault completion
if grep -Fxq "complete -o nospace -C $HOME/.arkade/bin/vault vault" "$ZSHRC"; then
    printf "\e[1;32mOK\e[m: Vault completion line is present in .zshrc.\n" >/dev/null 2>&1
else
    echo "complete -o nospace -C $HOME/.arkade/bin/vault vault" >> "$ZSHRC"
    printf "\e[1;33mCHANGED\e[m: Vault completion line has been added to .zshrc.\n"
fi