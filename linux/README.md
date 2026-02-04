## What the phylosophy here ?

A dotfile project is nice but what install the tools and setup the autocompletion. 

Actually, there is several layers in this workstation automation:
- Some minimal OS prerequisities
- OS update
- tmux install and config
- tools installation and auto-completions

For the tools, we try as much as possible to install them with `arkade` which brings benefits like:
- Uniform way to install github tools (which usually have different install methods)
- Packages by default installed in user homedir
- Easy to update
- Include most of the devops tools

**Important Notice:**
- For most of tools which have the auto-completion and are installable, use the standard `install_tools.sh`.
- For the tools installable with `arkade` but without auto-completion included, use `annoying_tools.sh` and eventually create a custom completion script.
- For the tools non-installable with `arkade`, create your own custom tools. 


## Some guidlines

* Ideally, the `just` should run on any Linux distro... but if works on *debian-like*, it's already great.

* Try to keep everything in the user homedir as much as possible.

* Make each script as much autonomious as possible. 

* Make those script as much idempotent as possible.

* Follow Ansible color output:

```bash
printf "\e[1;33mCHANGED\e[m: Yellow for CHANGED, when action changed something.\n"
printf "\e[1;33mWARN\e[m: Yellow for WARN as well.\n"
printf "\e[1;32mOK\e[m: Green for OK when it was already done.\n"
printf "\e[1;34mINFO\e[m: Blue for real INFO.\n"
printf "\e[1;31mERROR\e[m: Red for ERRORS when something went wrong.\n"
```

## Some helpers

```bash
# Colors
BLUE="\e[1;34m"
YELLOW="\e[1;33m"
GREEN="\e[1;32m"
RED="\e[1;31m"
RESET="\e[m"

# Helper: print colored info
info() {
  echo -e "${BLUE}INFO:${RESET} $1"
}
warn() {
  echo -e "${YELLOW}WARN:${RESET} $1"
}
changed() {
  echo -e "${YELLOW}CHANGED:${RESET} $1"
}
ok() {
  echo -e "${GREEN}OK:${RESET} $1"
}
error() {
  echo -e "${RED}ERROR:${RESET} $1"
}
```