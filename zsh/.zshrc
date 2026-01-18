# =============================================================================
# 1. Path & Base Configuration
# =============================================================================
# Ensure Homebrew and standard paths are first
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Editor Defaults
export EDITOR='nvim'
export VISUAL='nvim'
export TERMINAL='ghostty'

# History Settings
HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt APPEND_HISTORY
setopt SHARE_HISTORY

# Standard Zsh Options (Since zoxide is gone, these are important for 'cd')
setopt autocd              # Change directory just by typing its name
setopt auto_pushd          # Keep directory history
setopt pushd_ignore_dups   # Don't duplicate history

# =============================================================================
# 2. Initialize Mise (The Tool Manager)
# =============================================================================
# This must run EARLY so that 'starship', 'fzf', etc. are found
eval "$(mise activate zsh)"

# =============================================================================
# 3. Shell Plugins (Zinit)
# =============================================================================
# Define where Zinit lives
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"

# Just source it (It was installed by install.sh)
source "${ZINIT_HOME}/zinit.zsh"

# Plugins
zinit light zsh-users/zsh-syntax-highlighting
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light Aloxaf/fzf-tab
zinit light jeffreytse/zsh-vi-mode

# Snippets (OMZ)
zinit snippet OMZP::git
zinit snippet OMZP::sudo
zinit snippet OMZP::docker
zinit snippet OMZP::command-not-found

# Load completions
autoload -Uz compinit && compinit
zinit cdreplay -q

# =============================================================================
# 4. Tool Initializations
# =============================================================================
# Starship Prompt
eval "$(starship init zsh)"

# Direnv (Environment manager)
eval "$(direnv hook zsh)"

# FZF (Fuzzy Finder) Configuration
source <(fzf --zsh)
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

# =============================================================================
# 5. Aliases
# =============================================================================
# File System (using eza instead of ls)
alias ls='eza --icons --git --group-dirs=first'
alias l='ls -l'
alias la='ls -la'
alias lt='ls --tree --level=2'

# Cat (using bat)
alias cat='bat --style=plain'

# Git
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -m'
alias gs='git status'
alias gp='git push'
alias gpl='git pull'
alias gl='git log --oneline --graph --decorate'
alias gco='git checkout'
alias lg='lazygit'

# Networking
alias iplocal="ipconfig getifaddr en0"
alias ipexternal="curl -s ifconfig.me"

# Misc
alias zconfig="zed ~/.zshrc"
alias reload="source ~/.zshrc"
alias ..="cd .."
alias ...="cd ../.."
