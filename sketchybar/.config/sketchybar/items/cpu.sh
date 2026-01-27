#!/bin/bash
# =============================================================================
# CPU Usage Item
# =============================================================================
# Displays CPU usage percentage from sketchybar-system-stats
# Color-coded: green (low) -> peach (medium) -> red (high)
# =============================================================================

source "$CONFIG_DIR/colors.sh"

cpu=(
    icon=$ICON_CPU
    icon.color=$GREEN
    label="0%"
    update_freq=2
    script="$CONFIG_DIR/plugins/cpu.sh"
)

sketchybar --add item cpu right \
    --set cpu "${cpu[@]}" \
    --subscribe cpu system_stats
