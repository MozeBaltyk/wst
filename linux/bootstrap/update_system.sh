# Updates and upgrades the system using apt.
# udpate_system:
#!/usr/bin/env bash
printf "\e[1;34mINFO\e[m: Updating the system...\n"
sudo apt update >/dev/null 2>&1
printf "\e[1;34mINFO\e[m: Upgrading the system...\n"
sudo apt full-upgrade -y >/dev/null 2>&1
printf "\e[1;34mINFO\e[m: Removing unused packages...\n"
sudo apt autoremove -y >/dev/null 2>&1
printf "\e[1;34mINFO\e[m: Cleaning up packages...\n"
sudo apt autoclean >/dev/null 2>&1  && sudo apt clean >/dev/null 2>&1
printf "\e[1;32mINFO\e[m: System update and upgrade completed.\n"