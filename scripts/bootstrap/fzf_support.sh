# Adds fzf completion and key-binfing
#!/usr/bin/env bash
ZSH="$HOME/.oh-my-zsh"
ZSH_COMPLETIONS_DIR="$ZSH/completions"
URL="https://raw.githubusercontent.com/junegunn/fzf/master/shell"
COMPLETION_URL="$URL/completion.zsh"
KEY_BINDINGS_URL="$URL/key-bindings.zsh"
mkdir -p "$ZSH_COMPLETIONS_DIR"
if [[ ! -f "$ZSH_COMPLETIONS_DIR/completion.zsh" ]]; then
curl -sSL $COMPLETION_URL -o "$ZSH_COMPLETIONS_DIR/completion.zsh"
printf "\e[1;32mINFO\e[m: completion.zsh downloaded successfully.\n"
fi
if [[ ! -f "$ZSH_COMPLETIONS_DIR/key-bindings.zsh" ]]; then
curl -sSL $KEY_BINDINGS_URL -o "$ZSH_COMPLETIONS_DIR/key-bindings.zsh"
printf "\e[1;32mINFO\e[m: key-bindings.zsh downloaded successfully.\n"
fi
if grep -q "completion.zsh" ~/.zshrc; then
printf "\e[1;34mINFO\e[m: completion.zsh is already sourced in ~/.zshrc.\n"
else
echo '[[ $- == *i* ]] && source "$ZSH/completions/completion.zsh" 2> /dev/null' >> ~/.zshrc
printf "\e[1;32mINFO\e[m: completion.zsh added to ~/.zshrc.\n"
fi
if grep -q "key-bindings.zsh" ~/.zshrc; then
printf "\e[1;34mINFO\e[m: key-bindings.zsh is already sourced in ~/.zshrc.\n"
else
echo 'source "$ZSH/completions/key-bindings.zsh"' >> ~/.zshrc
printf "\e[1;32mINFO\e[m: key-bindings.zsh added to ~/.zshrc.\n"
fi