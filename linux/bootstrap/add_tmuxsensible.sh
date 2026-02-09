#!/usr/bin/env bash
tmux_config_path="$HOME/.config/tmux"
tmux_config_file="$tmux_config_path/tmux.conf"

if command -v tmux >/dev/null 2>&1; then
  if grep -q "set -g @plugin 'tmux-plugins/tmux-sensible'" "$tmux_config_file"; then
      printf "\e[1;32mOK\e[m: tmux-sensible \e[1;32mis present in $tmux_config_file.\n"
  else
      printf "set -g @plugin 'tmux-plugins/tmux-sensible'\n" >> "$tmux_config_file"
      printf "\e[1;33mCHANGED\e[m: tmux-sensible line has been added to $tmux_config_file.\n"
  fi
else
  printf "\e[1;31mERROR\e[m: tmux command not found. Please install tmux first.\n"
fi
