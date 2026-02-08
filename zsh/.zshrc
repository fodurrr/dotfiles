# =============================================================================
# 1. Path & Base Configuration
# =============================================================================
# Ensure Homebrew and standard paths are first
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/local/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# PostgreSQL (Homebrew keg-only formula)
[[ -d /opt/homebrew/opt/postgresql@17/bin ]] && export PATH="/opt/homebrew/opt/postgresql@17/bin:$PATH"

# Editor Defaults (fallback chain: VSCode → Zed → helix → vim)
if command -v code &>/dev/null; then
    export EDITOR='code --wait'
elif command -v zed &>/dev/null; then
    export EDITOR='zed --wait'
elif command -v helix &>/dev/null; then
    export EDITOR='helix --wait'
else
    export EDITOR='vim'
fi
export VISUAL="$EDITOR"
export TERMINAL='ghostty'

# History Settings
HISTSIZE=10000
HISTFILE=~/.zsh_history
SAVEHIST=$HISTSIZE
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt APPEND_HISTORY
setopt SHARE_HISTORY

# Standard Zsh Options
setopt autocd
setopt auto_pushd
setopt pushd_ignore_dups

# =============================================================================
# 2. Initialize Mise (The Version Manager)
# =============================================================================
command -v mise &>/dev/null && eval "$(mise activate zsh)" || echo "⚠️  mise not found" >&2

# =============================================================================
# 3. Sheldon Plugin Manager
# =============================================================================
# Loads all plugins defined in ~/.config/sheldon/plugins.toml
command -v sheldon &>/dev/null && eval "$(sheldon source)" || echo "⚠️  sheldon not found" >&2

# =============================================================================
# 4. Tool Initializations
# =============================================================================
# Starship Prompt
command -v starship &>/dev/null && eval "$(starship init zsh)" || echo "⚠️  starship not found" >&2

# Direnv (Environment manager) - silent if not installed
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"

# FZF (Fuzzy Finder) Configuration
command -v fzf &>/dev/null && source <(fzf --zsh) || echo "⚠️  fzf not found" >&2
export FZF_DEFAULT_OPTS=" \
--color=bg+:#313244,bg:#1e1e2e,spinner:#f5e0dc,hl:#f38ba8 \
--color=fg:#cdd6f4,header:#f38ba8,info:#cba6f7,pointer:#f5e0dc \
--color=marker:#f5e0dc,fg+:#cdd6f4,prompt:#cba6f7,hl+:#f38ba8"

# =============================================================================
# 5. Aliases
# =============================================================================
# File System (using eza instead of ls)
if command -v eza &>/dev/null; then
    alias ls='eza --icons --git'
    alias l='eza --icons --git'
    alias la='eza --long --all --header --icons --git'
    alias lt='eza --icons --git --tree --level=2'
    alias lta='eza --all --icons --git --tree --level=2'
    alias tree='eza --tree --icons --level=3'  # Replaces brew tree
fi

# Cat (using bat)
if command -v bat &>/dev/null; then
    alias cat='bat --style=plain'
fi

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
# alias lg='lazygit'  # Uncomment when lazygit is installed via mise

# Yazi (force command execution to avoid autocd conflict with ~/dotfiles/yazi)
alias yazi='command yazi'

# Other aliases
alias iplocal="ipconfig getifaddr en0"
alias ipexternal="curl -s ifconfig.me"

alias zconfig="zed ~/.zshrc"
alias reload="source ~/.zshrc"

alias ..="cd .."
alias ...="cd ../.."

# =============================================================================
# 6. AI Agent Sandbox (SandVault)
# =============================================================================
# SandVault creates an isolated macOS user for running AI coding agents safely.
# Install: brew install sandvault && sv build
# The sandbox user can't access your personal files (~/, ~/.ssh, etc.)
#
# Usage:
#   sandbox-claude          # Claude Code in sandbox (from current dir)
#   sandbox-codex           # Codex CLI in sandbox
#   sandbox-gemini          # Gemini CLI in sandbox
#   sandbox <cmd>           # Any command in sandbox
#
if command -v sv &>/dev/null; then
    alias sandbox='sv shell'
    alias sandbox-claude='sv claude'
    alias sandbox-codex='sv codex'
    alias sandbox-gemini='sv gemini'
    # Shorthand versions
    alias svc='sv claude'
    alias svx='sv codex'
    alias svg='sv gemini'
fi

