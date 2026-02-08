# =============================================================================
# Logging Setup (after interactive prompts, before installation)
# =============================================================================

setup_logging() {
    LOG_FILE="$DOTFILES_DIR/install.log"

    # Initialize log file with header
    local profile_label="${SELECTED_PROFILES[*]}"
    [[ "$A_LA_CARTE_MODE" == true ]] && profile_label="a-la-carte"

    {
        echo "================================================================================"
        echo "Dotfiles Installation Log"
        echo "================================================================================"
        echo "Date:     $(date '+%Y-%m-%d %H:%M:%S')"
        echo "Host:     $(hostname)"
        echo "User:     $(whoami)"
        echo "Profiles: ${profile_label}"
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
}
