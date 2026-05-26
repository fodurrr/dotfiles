# =============================================================================
# .zprofile — login-shell init (sourced by non-interactive login shells)
# =============================================================================
# macOS-specific gotcha: non-interactive login shells (e.g. Pitchfork's
# `auto = ["start","stop"]` daemon spawns, some launchd-style entrypoints,
# `ssh user@host <cmd>`) source ONLY ~/.zprofile, not ~/.zshrc. Anything that
# must be available in those contexts has to be initialised here as well.
# Memory: feedback_mise_activation_zprofile.

# Mise (runtime version manager) — required for any tool managed by mise.
command -v mise &>/dev/null && eval "$(mise activate zsh)"

# Pitchfork (dev daemon supervisor — auto-start/stop pitchfork.toml daemons on cd)
# Reference: xpando-standards/process/pitchfork-process-supervision.md (AI Layer Phase 7c)
command -v pitchfork &>/dev/null && eval "$(pitchfork activate zsh)"
