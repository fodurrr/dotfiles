#!/bin/bash
# =============================================================================
# Preferences Item
# =============================================================================
# Click to open System Settings
# Part of system_controls bracket
# =============================================================================

preferences=(
    icon=$ICON_PREFERENCES
    icon.color=$ACCENT_COLOR
    label.drawing=off
    background.drawing=off
    click_script="open -a 'System Settings'"
)

sketchybar --add item preferences left \
    --set preferences "${preferences[@]}"
