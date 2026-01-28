#!/bin/bash
# =============================================================================
# Apple Menu Item
# =============================================================================
# Click to open Raycast with Power Menu search
# =============================================================================

apple_logo=(
    icon=$ICON_APPLE
    icon.font="SF Pro:Black:16.0"
    icon.color=$ACCENT_COLOR
    label.drawing=off
    click_script="open raycast://script-commands/power-menu"
)

sketchybar --add item apple.logo left \
    --set apple.logo "${apple_logo[@]}"
