# Adds autostart tmux in new zsh sessions
#!/usr/bin/env bash
autostart='if [[ ! $TERM =~ screen ]] && [[ ! $TERM =~ tmux ]] && [[ -z $TMUX ]]; then exec tmux; fi'

if grep -Fxq "$autostart" ~/.zshrc; then
    printf "\e[1;32mOK\e[m: tmux \e[1;32mis already present in your .zshrc file.\n"
else
    echo "$autostart" | cat - ~/.zshrc > temp && mv temp ~/.zshrc
    printf "\e[1;33mCHANGED\e[m: tmux has been successfully added to your .zshrc file.\n"
fi
if [ ! -f "$HOME/.tmux.conf" ]; then
    touch "$HOME/.tmux.conf"
    printf "\e[1;33mCHANGED\e[m: ~/.tmux.conf file has been created.\n"
else
    printf "\e[1;32mOK\e[m: ~/.tmux.conf file already exists.\n" >/dev/null 2>&1
fi
if ! grep -q "tmux" ~/.zshrc; then
    sed -i 's/^plugins=(/plugins=(tmux /' ~/.zshrc
    printf "\e[1;33mCHANGED\e[m: tmux plugin has been added to .zshrc.\n"
else
    printf "\e[1;32mOK\e[m: tmux plugin \e[1;32mis already present in .zshrc.\n" >/dev/null 2>&1
fi
if ! grep -q "set-option -g mouse on" "$HOME/.tmux.conf"; then
    echo "set-option -g mouse on" >> "$HOME/.tmux.conf"
    printf "\e[1;33mCHANGED\e[m: Mouse mode has been added to ~/.tmux.conf.\n"
else
    printf "\e[1;32mOK\e[m: Mouse mode \e[1;32mis already present in ~/.tmux.conf.\n"
fi
