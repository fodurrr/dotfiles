#!/bin/bash

# =============================================================================
# Logging Setup (after interactive prompts, before installation)
# =============================================================================
LOG_FILE="$DOTFILES_DIR/install.log"

# Initialize log file with header
{
    echo "================================================================================"
    echo "Dotfiles Installation Log"
    echo "================================================================================"
    echo "Date:     $(date '+%Y-%m-%d %H:%M:%S')"
    echo "Host:     $(hostname)"
    echo "User:     $(whoami)"
    echo "Profiles: ${SELECTED_PROFILES[*]}"
    echo "Clean:    $CLEAN_MODE"
    echo "================================================================================"
    echo ""
} > "$LOG_FILE"

# Duplicate all output to log file (append mode)
exec > >(tee -a "$LOG_FILE") 2>&1

if [[ "$EXTRAS_MODE" != true ]]; then
    echo ""
    echo "Installing for profiles: ${SELECTED_PROFILES[*]}"
fi
