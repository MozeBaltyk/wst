# Installs ripgrep and generates its command completion file.
#!/usr/bin/env bash
ZSH="$HOME/.oh-my-zsh"
sudo apt install -y ripgrep >/dev/null 2>&1
mkdir -p $ZSH/completions
if [[ -s "$ZSH/completions/_rg" ]]; then
    printf "\e[1;34mINFO\e[m: rg completion already exists.\n" >/dev/null 2>&1
else
    printf "\e[1;33mINFO\e[m: Generating command completion file _rg...\n"
    url="https://raw.githubusercontent.com/BurntSushi/ripgrep/master/complete/_rg"
    curl $url > "$ZSH/completions/_rg"
fi
