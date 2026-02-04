# Checks if tmux-logging plugin is installed and adds it if not.
#!/usr/bin/env bash
if command -v tmux >/dev/null 2>&1; then
    if grep -q "set -g @plugin 'tmux-plugins/tmux-logging'" ~/.tmux.conf; then
        printf "\e[1;32mOK\e[m: tmux-logging \e[1;32mis present in ~/.tmux.conf.\n"
    else
        printf "set -g @plugin 'tmux-plugins/tmux-logging'\n" >> ~/.tmux.conf
        printf "\e[1;33mCHANGED\e[m: tmux-logging line has been added to ~/.tmux.conf.\n"
        printf "\e[1;34mINFO\e[m: Please restart your tmux session to activate the plugin.\n"
    fi
else
    printf "\e[1;31mERROR\e[m: tmux command not found. Please install tmux first.\n"
fi
