#!/bin/bash
# =============================================================================
# Activity Monitor Item
# =============================================================================
# Click to open Activity Monitor
# =============================================================================

activity=(
    icon=$ICON_ACTIVITY
    icon.color=$ACCENT_COLOR
    label.drawing=off
    click_script="open -a 'Activity Monitor'"
)

sketchybar --add item activity left \
    --set activity "${activity[@]}"
