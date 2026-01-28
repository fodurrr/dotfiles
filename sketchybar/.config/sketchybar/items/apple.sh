#!/bin/bash
# =============================================================================
# Apple Menu Item
# =============================================================================
# Click to open Raycast (type "Power Menu" for power actions)
# =============================================================================

apple_logo=(
    icon=$ICON_APPLE
    icon.font="SF Pro:Black:16.0"
    icon.color=$ACCENT_COLOR
    label.drawing=off
    click_script="open -a Raycast"
)

sketchybar --add item apple.logo left \
    --set apple.logo "${apple_logo[@]}"
