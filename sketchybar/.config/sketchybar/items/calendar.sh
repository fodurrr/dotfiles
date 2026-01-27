#!/bin/bash
# =============================================================================
# Calendar/Clock Item
# =============================================================================
# Displays date and time on the right
# Format: Mon 27 Jan 14:30
# Click to show calendar popup
# =============================================================================

calendar=(
    icon=$ICON_CALENDAR
    icon.color=$ACCENT_COLOR
    update_freq=30
    script="$CONFIG_DIR/plugins/calendar.sh"
    click_script="$CONFIG_DIR/plugins/calendar_click.sh"
)

sketchybar --add item calendar right \
    --set calendar "${calendar[@]}"
