#!/bin/bash
# =============================================================================
# Battery Item
# =============================================================================
# Displays battery level with appropriate icon
# Auto-hides on Mac mini (no battery)
# =============================================================================

source "$CONFIG_DIR/colors.sh"

battery=(
    icon=$ICON_BATTERY
    icon.color=$GREEN
    label=""
    update_freq=120
    script="$CONFIG_DIR/plugins/battery.sh"
)

sketchybar --add item battery right \
    --set battery "${battery[@]}" \
    --subscribe battery power_source_change system_woke
