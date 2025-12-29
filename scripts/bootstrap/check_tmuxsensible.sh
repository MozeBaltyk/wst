# Checks if tmux-sensible plugin is installed and adds it if not.
#!/usr/bin/env bash
if command -v tmux >/dev/null 2>&1; then
    if grep -q "set -g @plugin 'tmux-plugins/tmux-sensible'" ~/.tmux.conf; then
        printf "\e[1;34mINFO\e[m: tmux-sensible \e[1;32mis present in ~/.tmux.conf.\n"
    else
        printf "\e[1;33mINFO\e[m: tmux-sensible line is missing in ~/.tmux.conf. Adding it...\n"
        printf "set -g @plugin 'tmux-plugins/tmux-sensible'\n" >> ~/.tmux.conf
        printf "\e[1;32mINFO\e[m: tmux-sensible line has been added to ~/.tmux.conf.\n"
    fi
else
    printf "\e[1;31mERROR\e[m: tmux command not found. Please install tmux first.\n"
fi