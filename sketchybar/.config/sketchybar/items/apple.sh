#!/bin/bash
# =============================================================================
# Apple Menu Item
# =============================================================================
# Click to open Raycast with power search (shows Lock, Sleep, Restart, Shutdown)
# =============================================================================

apple_logo=(
    icon=$ICON_APPLE
    icon.font="SF Pro:Black:16.0"
    icon.color=$ACCENT_COLOR
    label.drawing=off
    click_script="open 'raycast://search/power'"
)

sketchybar --add item apple.logo left \
    --set apple.logo "${apple_logo[@]}"
