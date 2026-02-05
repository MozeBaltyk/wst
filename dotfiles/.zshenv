# Oh my Zsh configuration
export ZSH="$HOME/.oh-my-zsh"

# Include Arkade in $PATH
export PATH="$PATH:$HOME/.arkade/bin"

# Include custom scripts in $PATH
export PATH="$PATH:$HOME/.local/bin"

# Go
export GOPATH="$HOME/.local"

# Rust
export CARGO_HOME="$HOME/.local"

# Nvim
export PATH=$PATH:/usr/local/nvim/bin/nvim
export EDITOR=nvim
export VISUAL=nvim
export MANPAGER='nvim +Man!'

# Krew
export PATH="${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
