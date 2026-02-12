#!/bin/bash
set -e

# =============================================================================
# Dotfiles Installation Script - Two-Phase Architecture
# =============================================================================
# Phase 1: Bootstrap - Install infrastructure (runs for ALL profiles)
# Phase 2: Profile  - Install apps based on selected profile(s)
#
# Usage:
#   ./install.sh                          # Interactive mode
#   ./install.sh --profile=developer      # Non-interactive, single profile
#   ./install.sh -p dev -p devops         # Merge multiple profiles
#   ./install.sh --list-profiles          # Show available profiles
#   ./install.sh --list-installed         # Show installed apps (from apps.toml)
#   ./install.sh --clean                  # Strict cleanup mode
#   ./install.sh --extras                 # Install extra apps interactively
# =============================================================================

# =============================================================================
# Configuration
# =============================================================================
SELECTED_PROFILES=()
CLEAN_MODE=false
YES_MODE=false
INTERACTIVE=true
EXTRAS_MODE=false
A_LA_CARTE_MODE=false
A_LA_CARTE_SELECTED=""
A_LA_CARTE_REMOVE=""
RECONCILE_CASKS=false
RECONCILE_DRY_RUN=false
RECONCILE_ONLY=false
CLEAN_UNTRACKED=false
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR_REAL="$(cd "$DOTFILES_DIR" 2>/dev/null && pwd -P)"
APPS_CONFIG="$DOTFILES_DIR/apps.toml"

# Installation tracking for summary (newline+pipe delimited: "name|description\nname|description")
SUMMARY_INSTALLED=""
SUMMARY_SKIPPED=""
SUMMARY_REMOVED=""

# =============================================================================
# Error Handler
# =============================================================================
cleanup() {
    local exit_code=$?
    if [[ $exit_code -ne 0 ]]; then
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  Installation failed. Check the errors above."
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "Press [ENTER] to reload the shell anyway..."
        read
        exec zsh -l
    fi
}
trap cleanup EXIT

# =============================================================================
# Load Libraries
# =============================================================================
source "$DOTFILES_DIR/scripts/lib/platform.sh"
source "$DOTFILES_DIR/scripts/lib/package-manager.sh"
source "$DOTFILES_DIR/scripts/lib/logging.sh"
source "$DOTFILES_DIR/scripts/lib/app_config.sh"
source "$DOTFILES_DIR/scripts/lib/app_state.sh"
source "$DOTFILES_DIR/scripts/lib/stow.sh"
source "$DOTFILES_DIR/scripts/lib/mise.sh"
source "$DOTFILES_DIR/scripts/lib/summary.sh"

# =============================================================================
# Load Install Phases
# =============================================================================
source "$DOTFILES_DIR/scripts/install/list_installed.sh"
source "$DOTFILES_DIR/scripts/install/help.sh"
source "$DOTFILES_DIR/scripts/install/args.sh"
source "$DOTFILES_DIR/scripts/install/bootstrap.sh"
source "$DOTFILES_DIR/scripts/install/interactive.sh"
source "$DOTFILES_DIR/scripts/install/logging.sh"
source "$DOTFILES_DIR/scripts/install/clean_guard.sh"
source "$DOTFILES_DIR/scripts/install/reconcile_casks.sh"
source "$DOTFILES_DIR/scripts/install/clean_review.sh"
source "$DOTFILES_DIR/scripts/install/extras.sh"
source "$DOTFILES_DIR/scripts/install/alacarte.sh"
source "$DOTFILES_DIR/scripts/install/layer_homebrew.sh"
source "$DOTFILES_DIR/scripts/install/layer_linux.sh"
source "$DOTFILES_DIR/scripts/install/layer_stow.sh"
source "$DOTFILES_DIR/scripts/install/layer_mise.sh"
source "$DOTFILES_DIR/scripts/install/layer_curl.sh"
source "$DOTFILES_DIR/scripts/install/raycast.sh"
source "$DOTFILES_DIR/scripts/install/terminal.sh"
source "$DOTFILES_DIR/scripts/install/summary.sh"

# =============================================================================
# Run
# =============================================================================
parse_args "$@"
run_bootstrap
run_profile_selection
setup_logging
check_clean_safety
run_extras_mode
run_reconcile_casks
if [[ "$RECONCILE_ONLY" == true ]]; then
    show_reconcile_summary_and_exit
fi
run_alacarte_removals

# Platform-aware layer selection
PLATFORM=$(detect_platform)
if [[ "$PLATFORM" == "macos" ]]; then
    run_layer_homebrew
elif [[ "$PLATFORM" == "linux" ]]; then
    run_layer_linux
else
    log_warning "Unsupported platform '$PLATFORM'; skipping package layer"
fi

generate_mise_config
run_layer_stow
run_layer_mise
run_layer_curl
configure_raycast
configure_terminal
show_summary_and_reload
