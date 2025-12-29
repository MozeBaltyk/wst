# Checks if /etc/resolv.conf is a symlink and changes it to a file if needed.
#!/usr/bin/env bash
if [[ -L /etc/resolv.conf ]]; then
    printf "\e[1;33mINFO\e[m: /etc/resolv.conf is a symlink. Changing it to a file...\n"
    # Get the target of the symlink
    target=$(readlink -f /etc/resolv.conf)
    # Remove the symlink
    sudo rm /etc/resolv.conf
    # Create a new empty /etc/resolv.conf file
    sudo touch /etc/resolv.conf
    # Set the target as the content of the new file
    printf "%s" "$target" | sudo tee /etc/resolv.conf
else
    printf "\e[1;34mINFO\e[m: /etc/resolv.conf \e[1;32mis already a regular file.\n"
fi
if grep -q "nameserver 8.8.8.8" /etc/resolv.conf; then
    printf "\e[1;34mINFO\e[m: nameserver 8.8.8.8 \e[1;32mis already present in /etc/resolv.conf.\n"
else
    # Add nameserver 8.8.8.8 to /etc/resolv.conf
    printf "\e[1;33mINFO\e[m: Adding nameserver 8.8.8.8 to /etc/resolv.conf...\n"
    echo "nameserver 8.8.8.8" | sudo tee -a /etc/resolv.conf > /dev/null 2>&1
fi