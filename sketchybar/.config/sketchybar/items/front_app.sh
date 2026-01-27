#!/bin/bash
# =============================================================================
# Front App Item
# =============================================================================
# Displays the currently focused application name
# Auto-updates on app switch via front_app_switched event
# =============================================================================

front_app=(
    icon.drawing=off
    label.font="JetBrainsMono Nerd Font:Bold:13.0"
    label.color=$TEXT_COLOR
    script="$CONFIG_DIR/plugins/front_app.sh"
)

sketchybar --add item front_app left \
    --set front_app "${front_app[@]}" \
    --subscribe front_app front_app_switched
