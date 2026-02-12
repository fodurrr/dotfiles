# =============================================================================
# Installation Summary (Table Display)
# =============================================================================

get_login_shell() {
    local shell_path=""
    if command -v getent >/dev/null 2>&1; then
        shell_path=$(getent passwd "$USER" 2>/dev/null | awk -F: '{print $7}')
    fi
    if [[ -z "$shell_path" ]]; then
        shell_path="${SHELL:-}"
    fi
    echo "$shell_path"
}

ensure_linux_zsh_default_shell() {
    if [[ "$(get_current_platform)" != "linux" ]]; then
        return 0
    fi

    local zsh_path
    zsh_path=$(command -v zsh 2>/dev/null || true)
    if [[ -z "$zsh_path" ]]; then
        log_error "zsh is required but not installed"
        return 1
    fi

    local login_shell
    login_shell=$(get_login_shell)
    if [[ "$(basename "$login_shell")" == "zsh" ]]; then
        return 0
    fi

    local should_change=false
    if [[ "$YES_MODE" == true ]]; then
        should_change=true
    else
        echo ""
        echo "Your login shell is not zsh: ${login_shell:-unknown}"
        if command -v gum >/dev/null 2>&1; then
            if gum confirm "Set zsh as your default login shell now?"; then
                should_change=true
            fi
        else
            read -r -p "Set zsh as your default login shell now? (y/n) " reply
            case "$reply" in
                y|Y|yes|YES) should_change=true ;;
            esac
        fi
    fi

    if [[ "$should_change" != true ]]; then
        log_error "Login shell remains unchanged. Run: chsh -s \"$zsh_path\" \"$USER\""
        return 1
    fi

    local changed=false
    if [[ "$YES_MODE" == true ]]; then
        if command -v sudo >/dev/null 2>&1 && sudo -n true >/dev/null 2>&1; then
            if sudo chsh -s "$zsh_path" "$USER" >/dev/null 2>&1; then
                changed=true
            fi
        fi
        if [[ "$changed" != true ]]; then
            if chsh -s "$zsh_path" "$USER" >/dev/null 2>&1 < /dev/null; then
                changed=true
            fi
        fi
    else
        if chsh -s "$zsh_path" "$USER"; then
            changed=true
        fi
    fi

    if [[ "$changed" != true ]]; then
        log_error "Failed to set zsh as default shell. Run manually: chsh -s \"$zsh_path\" \"$USER\""
        return 1
    fi

    log_success "Default login shell updated to zsh"
    return 0
}

show_summary_and_reload() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Installation Summary"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    if [[ "$A_LA_CARTE_MODE" == true ]]; then
        echo "  Profiles: a-la-carte"
    else
        echo "  Profiles: ${SELECTED_PROFILES[*]}"
    fi
    echo ""

    if [[ -n "$SUMMARY_INSTALLED" ]]; then
        echo -e "  ${GREEN}Newly Installed${NC}"
        echo ""
        print_summary_table "$SUMMARY_INSTALLED" "✓" "New"
    fi

    if [[ -n "$SUMMARY_SKIPPED" ]]; then
        echo -e "  ${BLUE}Already Installed${NC}"
        echo ""
        print_summary_table "$SUMMARY_SKIPPED" "ℹ" "Skipped"
    fi

    if [[ -n "$SUMMARY_REMOVED" ]]; then
        echo -e "  ${YELLOW}Removed${NC}"
        echo ""
        print_summary_table "$SUMMARY_REMOVED" "⚠" "Removed"
    fi

    if [[ -z "$SUMMARY_INSTALLED" && -z "$SUMMARY_SKIPPED" && -z "$SUMMARY_REMOVED" ]]; then
        echo "  No changes made"
    fi

    ensure_linux_zsh_default_shell

    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "Press [ENTER] to reload the shell..."
    read
    exec zsh -l
}
