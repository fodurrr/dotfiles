#!/bin/bash

# =============================================================================
# Terminal.app Settings (defaults write)
# =============================================================================
# Check if terminal-config is in selected profiles
TERMINAL_IN_PROFILE=false
for app_key in $(get_all_apps); do
    if [[ "$app_key" == "terminal-config" ]] && app_in_profile "$app_key"; then
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
        # Import the profile only if it isn't already in Terminal preferences
        PROFILE_IMPORTED=false
        if defaults read com.apple.Terminal "Window Settings" 2>/dev/null | grep -Fq "$PROFILE_NAME"; then
            PROFILE_IMPORTED=true
        fi

        if [[ "$PROFILE_IMPORTED" == false ]]; then
            log_info "Importing $PROFILE_NAME profile..."
            open "$TERMINAL_PROFILE"
            sleep 2  # Wait for Terminal.app to import the profile
        else
            log_info "$PROFILE_NAME profile already imported; skipping import..."
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
