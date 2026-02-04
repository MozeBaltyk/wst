# Check if tmux plugin manager (tpm) is installed and install if not present.
#!/usr/bin/env bash
# Install tmux plugin manager (tpm) if not already installed
if [ ! -d "$HOME/.tmux/plugins/tpm" ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
    printf "\e[1;33mCHANGED\e[m: tmux plugin manager (tpm) has been installed.\n"
else
    printf "\e[1;32mOK\e[m: tmux plugin manager (tpm) \e[1;32mis already installed.\n"
fi
# Ensure tpm is sourced in .tmux.conf
if ! grep -q "run -b ~/.tmux/plugins/tpm/tpm" "$HOME/.tmux.conf"; then
    echo "run -b ~/.tmux/plugins/tpm/tpm" >> "$HOME/.tmux.conf"
    printf "\e[1;33mCHANGED\e[m: tpm has been added to ~/.tmux.conf.\n"
else
    printf "\e[1;32mOK\e[m: tpm is already present in ~/.tmux.conf.\n" >/dev/null 2>&1
fi