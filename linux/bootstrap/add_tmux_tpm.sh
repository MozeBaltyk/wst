#!/usr/bin/env bash

# Autostart tmux if not already
autostart='if [[ ! $TERM =~ screen ]] && [[ ! $TERM =~ tmux ]] && [[ -z $TMUX ]]; then exec tmux; fi'
if grep -Fxq "$autostart" ~/.zshrc; then
    printf "\e[1;32mOK\e[m: tmux \e[1;32mis already present in your .zshrc file.\n"
else
    # Add autostart line to the top of current .zshrc
    echo "$autostart" | cat - ~/.zshrc > temp && mv temp ~/.zshrc
    printf "\e[1;33mCHANGED\e[m: tmux has been successfully added to your .zshrc file.\n"
fi
# Create tmux config file if it does not exist
tmux_config_path="$HOME/.config/tmux"
tmux_config_file="$tmux_config_path/tmux.conf"
if [ ! -f "$tmux_config_file" ]; then
    mkdir -p "$tmux_config_path"
    touch "$tmux_config_file"
    printf "\e[1;33mCHANGED\e[m: $tmux_config_file file has been created.\n"
else
    printf "\e[1;32mOK\e[m: $tmux_config_file file already exists.\n"
fi
# Add tmux plugin to .zshrc if not already present
if ! grep -q "tmux" ~/.zshrc; then
    sed -i 's/^plugins=(/plugins=(tmux /' ~/.zshrc
    printf "\e[1;33mCHANGED\e[m: tmux plugin has been added to .zshrc.\n"
else
    printf "\e[1;32mOK\e[m: tmux plugin is already present in .zshrc.\n"
fi
# Enable mouse mode in tmux config if not already present
if ! grep -q "set-option -g mouse on" "$tmux_config_file"; then
    echo "set-option -g mouse on" >> "$tmux_config_file"
    printf "\e[1;33mCHANGED\e[m: Mouse mode has been added to $tmux_config_file.\n"
else
    printf "\e[1;32mOK\e[m: Mouse mode is already present in $tmux_config_file.\n"
fi
