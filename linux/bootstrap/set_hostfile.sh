# Checks if /etc/hosts is owned by the user and changes the ownership if not.
#!/usr/bin/env bash
if [[ "$(stat -c '%U' /etc/hosts)" != "${USER}" ]]; then
    sudo chown ${USER}:${USER} /etc/hosts
    printf "\e[1;33mCHANGED\e[m: Ownership of /etc/hosts changed to ${USER}.\n"
else
    printf "\e[1;32mOK\e[m: /etc/hosts is already owned by ${USER}.\n"
fi