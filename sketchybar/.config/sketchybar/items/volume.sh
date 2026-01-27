#!/bin/bash
# =============================================================================
# Volume Control Item
# =============================================================================
# Displays current volume level
# Click to toggle mute
# Scroll to adjust volume
# =============================================================================

source "$CONFIG_DIR/colors.sh"

volume=(
    icon=$ICON_VOLUME
    icon.color=$SKY
    label="50%"
    script="$CONFIG_DIR/plugins/volume.sh"
    click_script="$CONFIG_DIR/plugins/volume.sh toggle"
)

sketchybar --add item volume right \
    --set volume "${volume[@]}" \
    --subscribe volume volume_change mouse.scrolled.global
