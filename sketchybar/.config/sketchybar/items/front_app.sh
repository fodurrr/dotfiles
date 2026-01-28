#!/bin/bash
# =============================================================================
# Front App Item
# =============================================================================
# Displays the currently focused application name and window title
# Styled like active workspace (green background, dark text)
# Auto-updates on app switch via front_app_switched event
# =============================================================================

front_app=(
    icon.drawing=off
    label.font="JetBrainsMono Nerd Font:Bold:13.0"
    label.color=$BASE
    label.padding_left=8
    label.padding_right=8
    background.color=$HIGHLIGHT
    background.corner_radius=5
    background.height=24
    background.drawing=on
    script="$CONFIG_DIR/plugins/front_app.sh"
)

sketchybar --add item front_app left \
    --set front_app "${front_app[@]}" \
    --subscribe front_app front_app_switched
