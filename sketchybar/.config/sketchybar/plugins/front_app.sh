#!/bin/bash
# =============================================================================
# Front App Plugin
# =============================================================================
# Updates the front_app item with app name and window title
# Format: "AppName - WindowTitle" or just "AppName" if no title
# Triggered by front_app_switched event
# =============================================================================

# Get the frontmost application name
if [ "$SENDER" = "front_app_switched" ]; then
    APP_NAME="$INFO"
else
    APP_NAME=$(osascript -e 'tell application "System Events" to get name of first process whose frontmost is true' 2>/dev/null)
fi

# Get window title via AppleScript
WINDOW_TITLE=$(osascript -e "
    tell application \"System Events\"
        set frontApp to first process whose frontmost is true
        set appName to name of frontApp
        try
            tell process appName
                set windowTitle to name of front window
            end tell
        on error
            set windowTitle to \"\"
        end try
    end tell
    return windowTitle
" 2>/dev/null)

# Format: "AppName - WindowTitle" or just "AppName" if no title
if [ -n "$WINDOW_TITLE" ] && [ "$WINDOW_TITLE" != "$APP_NAME" ]; then
    # Truncate window title if too long (max 40 chars)
    if [ ${#WINDOW_TITLE} -gt 40 ]; then
        WINDOW_TITLE="${WINDOW_TITLE:0:37}..."
    fi
    LABEL="$APP_NAME - $WINDOW_TITLE"
else
    LABEL="$APP_NAME"
fi

sketchybar --set $NAME label="$LABEL"
