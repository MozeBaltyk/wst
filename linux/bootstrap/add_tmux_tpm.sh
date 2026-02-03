# Check if tmux plugin manager (tpm) is installed and install if not present.
#!/usr/bin/env bash
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    printf "\e[1;33mINFO\e[m: tmux plugin manager (tpm) not found. Installing...\n"
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    printf "\e[1;32mINFO\e[m: tmux plugin manager (tpm) has been installed.\n"
else
    printf "\e[1;34mINFO\e[m: tmux plugin manager (tpm) \e[1;32mis already installed.\n"
fi
printf "\e[1;33mINFO\e[m: Appending tpm to ~/.tmux.conf...\n"
if ! grep -q "run -b ~/.tmux/plugins/tpm/tpm" "$HOME/.tmux.conf"; then
    echo "run -b ~/.tmux/plugins/tpm/tpm" >> "$HOME/.tmux.conf"
    printf "\e[1;32mINFO\e[m: tpm has been added to ~/.tmux.conf.\n"
else
    printf "\e[1;32mINFO\e[m: tpm is already present in ~/.tmux.conf.\n" >/dev/null 2>&1
fi