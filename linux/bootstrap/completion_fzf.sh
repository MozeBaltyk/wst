# Adds fzf completion and key-binfing
#!/usr/bin/env bash
ZSH="$HOME/.oh-my-zsh"
ZSH_COMPLETIONS_DIR="$ZSH/completions"
URL="https://raw.githubusercontent.com/junegunn/fzf/master/shell"
COMPLETION_URL="$URL/completion.zsh"
KEY_BINDINGS_URL="$URL/key-bindings.zsh"

# FZF completions
mkdir -p "$ZSH_COMPLETIONS_DIR"
if [[ ! -f "$ZSH_COMPLETIONS_DIR/completion.zsh" ]]; then
curl -sSL $COMPLETION_URL -o "$ZSH_COMPLETIONS_DIR/completion.zsh"
printf "\e[1;33mCHANGED\e[m: completion.zsh downloaded successfully.\n"
fi

if grep -q "completion.zsh" ~/.zshrc; then
printf "\e[1;32mOK\e[m: completion.zsh is already sourced in ~/.zshrc.\n"
else
echo '[[ $- == *i* ]] && source "$ZSH/completions/completion.zsh" 2> /dev/null' >> ~/.zshrc
printf "\e[1;33mCHANGED\e[m: completion.zsh added to ~/.zshrc.\n"
fi

# FZF key-bindings
if [[ ! -f "$ZSH_COMPLETIONS_DIR/key-bindings.zsh" ]]; then
curl -sSL $KEY_BINDINGS_URL -o "$ZSH_COMPLETIONS_DIR/key-bindings.zsh"
printf "\e[1;33mCHANGED\e[m: key-bindings.zsh downloaded successfully.\n"
fi

if grep -q "key-bindings.zsh" ~/.zshrc; then
printf "\e[1;32mOK\e[m: key-bindings.zsh is already sourced in ~/.zshrc.\n"
else
echo 'source "$ZSH/completions/key-bindings.zsh"' >> ~/.zshrc
printf "\e[1;33mCHANGED\e[m: key-bindings.zsh added to ~/.zshrc.\n"
fi

# Add inv alias for fzf + neovim if not present
if ! grep -qF "alias inv=" "$HOME/.zshrc"; then
  echo "alias inv='nvim \$(fzf -m --preview=\"batcat --color=always {}\")'" >> "$HOME/.zshrc"
  printf "\e[1;33mCHANGED\e[m: Added inv alias to vim...\n"
else
  printf "\e[1;32mOK\e[m: inv alias for neovim and fzf \e[1;32mis already present in .zshrc.\n"
fi