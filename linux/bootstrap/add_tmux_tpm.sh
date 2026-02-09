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
# Install tmux plugin manager (tpm) if not already installed
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    printf "\e[1;33mCHANGED\e[m: tmux plugin manager (tpm) has been installed.\n"
else
    printf "\e[1;32mOK\e[m: tmux plugin manager (tpm) \e[1;32mis already installed.\n"
fi
# Ensure tpm is sourced in .tmux.conf
if ! grep -q "run -b ~/.tmux/plugins/tpm/tpm" "$tmux_config_file"; then
    echo "run -b ~/.tmux/plugins/tpm/tpm" >> "$tmux_config_file"
    printf "\e[1;33mCHANGED\e[m: tpm has been added to $tmux_config_file.\n"
else
    printf "\e[1;32mOK\e[m: tpm is already present in $tmux_config_file.\n" >/dev/null 2>&1
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
