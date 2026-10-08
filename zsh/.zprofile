# =============================================================================
# .zprofile — login-shell init (sourced by non-interactive login shells)
# =============================================================================
# macOS-specific gotcha: non-interactive login shells (e.g. some launchd-style
# entrypoints, `ssh user@host <cmd>`) source ONLY ~/.zprofile, not ~/.zshrc. Anything that
# must be available in those contexts has to be initialised here as well.
# Memory: feedback_mise_activation_zprofile.

# Mise (runtime version manager) — required for any tool managed by mise.
command -v mise &>/dev/null && eval "$(mise activate zsh)"

# Hermes Agent — ensure ~/.local/bin is on PATH
export PATH="$HOME/.local/bin:$PATH"

# Added by OrbStack: command-line tools and integration
# This won't be added again if you remove it.
source ~/.orbstack/shell/init.zsh 2>/dev/null || :

eval "$(/opt/homebrew/bin/brew shellenv)"
