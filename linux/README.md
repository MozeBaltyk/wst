## What the phylosophy here ?

A dotfile project is nice but what install the tools and setup the autocompletion. 

Actually, there is several layers in this workstation automation:
- Some minimal OS prereauisities
- OS update
- tmux install and config
- tools installation and auto-completions


## Some guidlines

* Ideally, the `just` should run on any Linux distro... but if works on *debian-like*, it's already great.

* Try to keep everything in the user homedir as much as possible.

* Make those script as much idempotent as possible.

* Follow Ansible color output:

```bash
printf "\e[1;33mCHANGED\e[m: Yellow for CHANGED, when action changed something.\n"
printf "\e[1;33mWARN\e[m: Yellow for WARN as well.\n"
printf "\e[1;32mOK\e[m: Green for OK when it was already done.\n"
printf "\e[1;34mINFO\e[m: Blue for real INFO.\n"
printf "\e[1;31mERROR\e[m: Red for ERRORS when something went wrong.\n"
```