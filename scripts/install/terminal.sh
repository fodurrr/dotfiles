# =============================================================================
# Terminal.app Settings (defaults write)
# =============================================================================

configure_terminal() {
    if [[ "$(get_current_platform)" != "macos" ]]; then
        return 0
    fi

    # Check if terminal-config is in selected profiles
    local TERMINAL_IN_PROFILE=false
    local app_key
    for app_key in $(get_all_apps); do
        if [[ "$app_key" == "terminal-config" ]] && app_selected_for_install "$app_key"; then
            TERMINAL_IN_PROFILE=true
            break
        fi
    done

    if [[ "$TERMINAL_IN_PROFILE" == true ]]; then
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  Terminal.app Settings"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

        PROFILE_NAME="Catppuccin-Macchiato"
        TERMINAL_PROFILE="$DOTFILES_DIR/terminal/${PROFILE_NAME}.terminal"

        if [[ -f "$TERMINAL_PROFILE" ]]; then
            profile_exists=false
            if defaults read com.apple.Terminal "Window Settings" 2>/dev/null | grep -q "$PROFILE_NAME"; then
                profile_exists=true
            fi

            if [[ "$profile_exists" != true ]]; then
                if [[ "$INTERACTIVE" == true ]]; then
                    log_info "Importing $PROFILE_NAME profile..."
                    open "$TERMINAL_PROFILE"
                    sleep 2  # Wait for Terminal.app to import the profile
                else
                    log_warning "$PROFILE_NAME profile not imported (non-interactive). Run: open \"$TERMINAL_PROFILE\""
                fi
            else
                reimport=false
                if [[ "$INTERACTIVE" == true ]]; then
                    if command -v gum &> /dev/null; then
                        if gum confirm "Re-import Terminal profile to apply updates? (Opens Terminal once)"; then
                            reimport=true
                        fi
                    else
                        read -p "Re-import Terminal profile to apply updates? (Opens Terminal once) [y/N] " -n 1 -r
                        echo
                        [[ $REPLY =~ ^[Yy]$ ]] && reimport=true
                    fi
                fi

                if [[ "$reimport" == true ]]; then
                    log_info "Re-importing $PROFILE_NAME profile..."
                    open "$TERMINAL_PROFILE"
                    sleep 2  # Wait for Terminal.app to import the profile
                else
                    log_info "$PROFILE_NAME profile already imported; skipping import"
                fi
            fi

            # Set font to match Ghostty (JetBrainsMono Nerd Font, size 16)
            log_info "Setting font to JetBrainsMono Nerd Font (size 16)..."
            osascript -e "tell application \"Terminal\" to set font name of settings set \"$PROFILE_NAME\" to \"JetBrainsMono Nerd Font\"" 2>/dev/null || true
            osascript -e "tell application \"Terminal\" to set font size of settings set \"$PROFILE_NAME\" to 16" 2>/dev/null || true

            # Set as default profile for new windows and startup
            log_info "Setting $PROFILE_NAME as default profile..."
            defaults write com.apple.Terminal "Default Window Settings" -string "$PROFILE_NAME"
            defaults write com.apple.Terminal "Startup Window Settings" -string "$PROFILE_NAME"

            log_success "Terminal.app configured with $PROFILE_NAME theme"
            add_to_summary INSTALLED "terminal-config" "terminal-config"
        else
            log_warning "Terminal profile not found: $TERMINAL_PROFILE"
        fi
    fi
}
