#!/bin/bash
# =============================================================================
# Memory Usage Item
# =============================================================================
# Displays RAM usage from sketchybar-system-stats
# =============================================================================

source "$CONFIG_DIR/colors.sh"

memory=(
    icon=$ICON_MEMORY
    icon.color=$LAVENDER
    label="0%"
    update_freq=5
    script="$CONFIG_DIR/plugins/memory.sh"
)

sketchybar --add item memory right \
    --set memory "${memory[@]}" \
    --subscribe memory system_stats
