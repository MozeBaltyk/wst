# Adds command completion for yq.
#_yq_completion:
#!/usr/bin/env bash
ZSH="$HOME/.oh-my-zsh"
mkdir -p $ZSH/completions
if [[ -s "$ZSH/completions/_yq" ]]; then
    printf "\e[1;34mINFO\e[m: yq completion already exists.\n" >/dev/null 2>&1
else
    printf "\e[1;33mINFO\e[m: Generating command completion file _yq...\n"
    yq shell-completion zsh > "$ZSH/completions/_yq"
fi