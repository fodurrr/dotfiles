# =============================================================================
# Installation Summary (Table Display)
# =============================================================================

get_target_user() {
    if [[ -n "${SUDO_USER:-}" && "${SUDO_USER}" != "root" ]]; then
        echo "$SUDO_USER"
        return 0
    fi

    if [[ -n "${USER:-}" ]]; then
        echo "$USER"
    else
        id -un
    fi
}

get_login_shell_for_user() {
    local target_user="$1"
    local shell_path=""
    if command -v getent >/dev/null 2>&1; then
        shell_path=$(getent passwd "$target_user" 2>/dev/null | awk -F: '{print $7}')
    fi
    if [[ -z "$shell_path" ]]; then
        shell_path="${SHELL:-}"
    fi
    echo "$shell_path"
}

ensure_shell_listed() {
    local shell_path="$1"
    if [[ -f /etc/shells ]]; then
        if ! grep -Fxq "$shell_path" /etc/shells 2>/dev/null; then
            log_error "Shell path is not listed in /etc/shells: $shell_path"
            log_error "Add it first, then rerun: echo \"$shell_path\" | sudo tee -a /etc/shells"
            return 1
        fi
    fi
    return 0
}

set_default_shell_for_user() {
    local target_user="$1"
    local shell_path="$2"
    local non_interactive="${3:-false}"
    local current_user

    current_user=$(id -un 2>/dev/null || echo "${USER:-}")

    if [[ "$EUID" -eq 0 ]]; then
        chsh -s "$shell_path" "$target_user"
        return $?
    fi

    if command -v sudo >/dev/null 2>&1; then
        if [[ "$non_interactive" == "true" ]]; then
            if sudo -n chsh -s "$shell_path" "$target_user" >/dev/null 2>&1; then
                return 0
            fi
        else
            if sudo chsh -s "$shell_path" "$target_user"; then
                return 0
            fi
        fi
    fi

    if [[ "$non_interactive" == "true" ]]; then
        return 1
    fi

    if [[ "$target_user" == "$current_user" ]]; then
        chsh -s "$shell_path"
    else
        chsh -s "$shell_path" "$target_user"
    fi

    return $?
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
    if ! ensure_shell_listed "$zsh_path"; then
        return 1
    fi

    local target_user
    target_user=$(get_target_user)

    local login_shell
    login_shell=$(get_login_shell_for_user "$target_user")
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
        log_error "Login shell remains unchanged. Run: chsh -s \"$zsh_path\" \"$target_user\""
        return 1
    fi

    if ! set_default_shell_for_user "$target_user" "$zsh_path" "$YES_MODE"; then
        log_error "Failed to set zsh as default shell. Run manually: chsh -s \"$zsh_path\" \"$target_user\""
        return 1
    fi

    login_shell=$(get_login_shell_for_user "$target_user")
    if [[ "$(basename "$login_shell")" != "zsh" ]]; then
        log_error "Shell change command completed but login shell is still: ${login_shell:-unknown}"
        log_error "Run manually: chsh -s \"$zsh_path\" \"$target_user\""
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
    if [[ "$YES_MODE" == true ]]; then
        echo "Reloading shell..."
    else
        echo "Press [ENTER] to reload the shell..."
        read -r
    fi

    if command -v zsh >/dev/null 2>&1; then
        exec zsh -l
    fi

    log_warning "zsh not found; skipping shell reload"
}
