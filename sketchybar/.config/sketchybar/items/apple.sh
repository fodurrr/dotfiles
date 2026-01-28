#!/bin/bash
# =============================================================================
# Apple Menu Item
# =============================================================================
# Click to open Raycast Power Menu (sleep/restart/shutdown/lock)
# =============================================================================

apple_logo=(
    icon=$ICON_APPLE
    icon.font="SF Pro:Black:16.0"
    icon.color=$ACCENT_COLOR
    padding_right=15
    label.drawing=off
    click_script="open 'raycast://extensions/raycast/system/power'"
)

sketchybar --add item apple.logo left \
    --set apple.logo "${apple_logo[@]}"
