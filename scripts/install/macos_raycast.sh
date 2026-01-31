#!/bin/bash

# =============================================================================
# Raycast Settings (defaults write)
# =============================================================================
# Check if raycast-config is in selected profiles
RAYCAST_IN_PROFILE=false
for app_key in $(get_all_apps); do
    if [[ "$app_key" == "raycast-config" ]] && app_in_profile "$app_key"; then
        RAYCAST_IN_PROFILE=true
        break
    fi
done

if [[ "$RAYCAST_IN_PROFILE" == true ]]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  Raycast Settings"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    # Enable Hyperkey on Caps Lock (keyCode 57)
    log_info "Enabling Hyperkey on Caps Lock..."
    defaults write com.raycast.macos raycast_hyperKey_state -dict \
        enabled -bool true \
        includeShiftKey -bool true \
        keyCode -int 57

    # Set global hotkey to Cmd+Space
    log_info "Setting global hotkey to Cmd+Space..."
    defaults write com.raycast.macos raycastGlobalHotkey -string "Command-49"

    log_success "Raycast settings configured"
    echo ""
    echo "  NOTE: One-time setup required:"
    echo "    1. Open Raycast -> Preferences (Cmd+,)"
    echo "    2. Extensions -> Script Commands -> Add Directories"
    echo "    3. Add: ~/.config/raycast/scripts"
    echo "    4. Click 'Reload Script Directories'"
fi
