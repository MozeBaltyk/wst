export ZSH="$HOME/.oh-my-zsh"

ZSH_THEME="robbyrussell"
plugins=(zsh-autosuggestions zsh-syntax-highlighting git)

# Load and config Oh My Zsh
source $ZSH/oh-my-zsh.sh

# Automatically update Oh My Zsh without prompting.
DISABLE_UPDATE_PROMPT=true

# fzf Completion and key bindings (deps on fzf_support.sh)
[[ $- == *i* ]] && source "$ZSH/completions/completion.zsh" 2> /dev/null
source "$ZSH/completions/key-bindings.zsh"

# init Auto-completion
autoload -U compinit; compinit

# Aliases
source $HOME/.aliases
