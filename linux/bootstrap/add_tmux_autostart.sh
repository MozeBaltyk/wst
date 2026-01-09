# Adds autostart tmux in new zsh sessions
#!/usr/bin/env bash
autostart='if [[ ! $TERM =~ screen ]] && [[ ! $TERM =~ tmux ]] && [[ -z $TMUX ]]; then exec tmux; fi'
printf "\e[1;34mINFO\e[m: Checking your .zshrc file...\n" >/dev/null 2>&1
if grep -Fxq "$autostart" ~/.zshrc; then
    printf "\e[1;34mINFO\e[m: tmux \e[1;32mis already present in your .zshrc file.\n"
else
    printf "\e[1;33mINFO\e[m: tmux is not present in your .zshrc file. Adding it now...\n"
    echo "$autostart" | cat - ~/.zshrc > temp && mv temp ~/.zshrc
    printf "\e[1;32mINFO\e[m: tmux has been successfully added to your .zshrc file.\n"
fi
if [ ! -f "$HOME/.tmux.conf" ]; then
    printf "\e[1;33mINFO\e[m: ~/.tmux.conf file not found. Creating...\n"
    touch "$HOME/.tmux.conf"
    printf "\e[1;32mINFO\e[m: ~/.tmux.conf file has been created.\n"
else
    printf "\e[1;34mINFO\e[m: ~/.tmux.conf file already exists.\n" >/dev/null 2>&1
fi
if ! grep -q "tmux" ~/.zshrc; then
    printf "\e[1;33mINFO\e[m: tmux plugin not found in .zshrc. Adding...\n"
    sed -i 's/^plugins=(/plugins=(tmux /' ~/.zshrc
fi
printf "\e[1;34mINFO\e[m: Checking mouse mode in ~/.tmux.conf...\n" >/dev/null 2>&1
if ! grep -q "set-option -g mouse on" "$HOME/.tmux.conf"; then
    printf "\e[1;33mINFO\e[m: Mouse mode not found in ~/.tmux.conf. Adding it now...\n"
    echo "set-option -g mouse on" >> "$HOME/.tmux.conf"
    printf "\e[1;32mINFO\e[m: Mouse mode has been added to ~/.tmux.conf.\n"
else
    printf "\e[1;34mINFO\e[m: Mouse mode \e[1;32mis already present in ~/.tmux.conf.\n"
fi

