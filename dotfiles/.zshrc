# ZSH 
ZSH_THEME="robbyrussell"
plugins=(zsh-autosuggestions zsh-syntax-highlighting git)

# init Auto-completion
autoload -U compinit; compinit

# Load Oh My Zsh
source $ZSH/oh-my-zsh.sh
DISABLE_UPDATE_PROMPT=true

# fzf Completion and key bindings (deps on fzf_support.sh)
[[ $- == *i* ]] && source "$ZSH/completions/completion.zsh" 2> /dev/null
source "$ZSH/completions/key-bindings.zsh"

# Aliases
source $HOME/.aliases
