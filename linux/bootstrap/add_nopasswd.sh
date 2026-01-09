# Adds the current user to the NOPASSWD sudo access if it's not already there.
#!/usr/bin/env bash
if sudo --non-interactive true 2>/dev/null; then
    printf "\e[1;34mINFO\e[m: ${USER} \e[1;32mhas NOPASSWD sudo access.\n"
else
    printf "\e[1;33mINFO\e[m: ${USER} does not have NOPASSWD sudo access. Adding...\n"
    sudo touch /etc/sudoers.d/${USER}
    echo "${USER} ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers.d/${USER}
    printf "\e[1;32mINFO\e[m: ${USER} has been added with NOPASSWD sudo access.\n"
fi