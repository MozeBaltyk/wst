#!/usr/bin/env bash

# Adds the current user to the NOPASSWD sudo access if it's not already there.
if sudo --non-interactive true 2>/dev/null; then
    printf "\e[1;32mOK\e[m: ${USER} \e[1;32mhas NOPASSWD sudo access.\n"
else
    sudo touch /etc/sudoers.d/${USER}
    echo "${USER} ALL=(ALL) NOPASSWD: ALL" | sudo tee -a /etc/sudoers.d/${USER}
    printf "\e[1;32mCHANGED\e[m: ${USER} has been added with NOPASSWD sudo access.\n"
fi