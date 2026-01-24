#!/bin/bash
# =============================================================================
# Calendar/Clock Item
# =============================================================================
# Displays date and time on the right
# =============================================================================

calendar=(
    icon=$ICON_CALENDAR
    icon.color=$ACCENT_COLOR
    update_freq=30
    script="$CONFIG_DIR/plugins/calendar.sh"
)

sketchybar --add item calendar right \
    --set calendar "${calendar[@]}"
