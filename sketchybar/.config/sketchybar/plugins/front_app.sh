#!/bin/bash
# =============================================================================
# Front App Plugin
# =============================================================================
# Updates the front_app item with the currently focused application name
# Triggered by front_app_switched event
# =============================================================================

# Get the frontmost application name
if [ "$SENDER" = "front_app_switched" ]; then
    APP_NAME="$INFO"
else
    APP_NAME=$(osascript -e 'tell application "System Events" to get name of first process whose frontmost is true' 2>/dev/null)
fi

sketchybar --set $NAME label="$APP_NAME"
