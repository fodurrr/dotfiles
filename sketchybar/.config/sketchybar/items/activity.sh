#!/bin/bash
# =============================================================================
# Activity Monitor Item
# =============================================================================
# Click to open Activity Monitor
# Part of system_controls bracket
# =============================================================================

activity=(
    icon=$ICON_ACTIVITY
    icon.color=$ACCENT_COLOR
    label.drawing=off
    background.drawing=off
    click_script="open -a 'Activity Monitor'"
)

sketchybar --add item activity left \
    --set activity "${activity[@]}"
