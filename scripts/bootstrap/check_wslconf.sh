# Checks if /etc/wsl.conf exists and disables the management of /etc/resolv.conf if needed.
#!/usr/bin/env bash
if [[ -f "/etc/wsl.conf" ]]; then
    if grep -q "^\[network\]" /etc/wsl.conf && grep -q "generateResolvConf = false" /etc/wsl.conf; then
        printf "\e[1;34mINFO\e[m: /etc/wsl.conf \e[1;32malready disables /etc/resolv.conf management.\n"
    else
        printf "\e[1;33mINFO\e[m: /etc/wsl.conf enable management of /etc/resolv.conf. Modifying...\n"
        echo -e "[network]\ngenerateResolvConf = false" | sudo tee -a /etc/wsl.conf > /dev/null
        printf "\e[1;32mINFO\e[m: /etc/wsl.conf modified to disable  management of /etc/resolv.conf.\n"
    fi
else
    printf "\e[1;34mINFO\e[m: /etc/wsl.conf does not exist.\n"
fi