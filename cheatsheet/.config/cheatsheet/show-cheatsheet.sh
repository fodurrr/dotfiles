#!/bin/bash
# =============================================================================
# Keybinds Cheatsheet Launcher
# =============================================================================
# Always uses AppleScript to open window in existing Ghostty instance.
# If Ghostty isn't running, launches it first.
# This ensures no extra dock icons.
# =============================================================================

CONFIG_DIR="${HOME}/.config/cheatsheet"
DISPLAY_SCRIPT="${CONFIG_DIR}/display-cheatsheet.sh"

if [[ ! -f "$DISPLAY_SCRIPT" ]]; then
    osascript -e 'display notification "Cheatsheet script not found" with title "Cheatsheet Error"'
    exit 1
fi

# Launch Ghostty if not running, then always use AppleScript for new window
if ! pgrep -q "Ghostty"; then
    # Launch Ghostty and wait for it to be ready
    open -a "Ghostty"
    sleep 0.5
fi

# Open new window in existing Ghostty instance (no second dock icon)
osascript <<'EOF'
tell application "Ghostty"
    activate
    tell application "System Events" to tell process "Ghostty"
        click menu item "New Window" of menu "File" of menu bar 1
    end tell
    delay 0.3
    tell application "System Events"
        keystroke "exec ~/.config/cheatsheet/display-cheatsheet.sh"
        keystroke return
    end tell
end tell
EOF
