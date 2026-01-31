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
#   ./install.sh --clean                  # Strict cleanup mode
#   ./install.sh --extras                 # Install extra apps interactively
# =============================================================================

# =============================================================================
# Configuration
# =============================================================================
SELECTED_PROFILES=()
CLEAN_MODE=false
INTERACTIVE=true
EXTRAS_MODE=false
DOCTOR_MODE=false
DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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
# Shared Functions
# =============================================================================
source "$DOTFILES_DIR/scripts/install/lib.sh"

# =============================================================================
# Parse Arguments
# =============================================================================
while [[ $# -gt 0 ]]; do
    case "$1" in
        -p|--profile)
            SELECTED_PROFILES+=("$2")
            INTERACTIVE=false
            shift 2
            ;;
        --profile=*)
            SELECTED_PROFILES+=("${1#*=}")
            INTERACTIVE=false
            shift
            ;;
        --clean)
            CLEAN_MODE=true
            shift
            ;;
        --extras)
            EXTRAS_MODE=true
            INTERACTIVE=false
            shift
            ;;
        --doctor)
            DOCTOR_MODE=true
            shift
            ;;
        --list-profiles)
            # Check if yq is available (installed during bootstrap)
            if command -v yq &> /dev/null && [[ -f "$APPS_CONFIG" ]]; then
                echo "Available profiles:"
                echo ""
                # Extract unique profiles from apps.toml
                grep -oE 'profiles = \[.*\]' "$APPS_CONFIG" | grep -oE '"[^"]+"' | tr -d '"' | sort -u | while read -r profile; do
                    # Count apps in this profile
                    count=$(grep -c "\"$profile\"" "$APPS_CONFIG" 2>/dev/null || echo "0")
                    printf "  %-12s (%d apps)\n" "$profile" "$count"
                done
            else
                echo "Run bootstrap first (./install.sh), then use --list-profiles"
                echo "Or check apps.toml for available profiles"
            fi
            exit 0
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Doctor mode: profile selection + read-only checks, then exit
if [[ "$DOCTOR_MODE" == true ]]; then
    source "$DOTFILES_DIR/scripts/install/phase2_profiles.sh"
    source "$DOTFILES_DIR/scripts/install/doctor.sh"
fi

# =============================================================================
# Execution Phases
# =============================================================================
source "$DOTFILES_DIR/scripts/install/phase1_bootstrap.sh"
source "$DOTFILES_DIR/scripts/install/phase2_profiles.sh"
source "$DOTFILES_DIR/scripts/install/logging_setup.sh"
source "$DOTFILES_DIR/scripts/install/extras_mode.sh"
source "$DOTFILES_DIR/scripts/install/layer_homebrew.sh"
source "$DOTFILES_DIR/scripts/install/layer_mise_config.sh"
source "$DOTFILES_DIR/scripts/install/layer_stow.sh"
source "$DOTFILES_DIR/scripts/install/layer_mise.sh"
source "$DOTFILES_DIR/scripts/install/layer_curl.sh"
source "$DOTFILES_DIR/scripts/install/macos_raycast.sh"
source "$DOTFILES_DIR/scripts/install/macos_terminal.sh"
source "$DOTFILES_DIR/scripts/install/summary.sh"
