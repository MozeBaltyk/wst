# Updates and upgrades the system using apt.
# udpate_system:
#!/usr/bin/env bash
sudo apt update >/dev/null 2>&1
printf "\e[1;33mCHANGED\e[m: Updated the system...\n"
sudo apt full-upgrade -y >/dev/null 2>&1
printf "\e[1;33mCHANGED\e[m: Upgraded the system...\n"
sudo apt autoremove -y >/dev/null 2>&1
printf "\e[1;33mCHANGED\e[m: Removed unused packages...\n"
sudo apt autoclean >/dev/null 2>&1  && sudo apt clean >/dev/null 2>&1
printf "\e[1;33mCHANGED\e[m: Cleaned up packages...\n"
printf "\e[1;32mSUCCESS\e[m: System update and upgrade completed.\n"