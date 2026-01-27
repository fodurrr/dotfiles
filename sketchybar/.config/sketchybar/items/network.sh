#!/bin/bash
# =============================================================================
# Network Status Item
# =============================================================================
# Displays active network connection (Ethernet or WiFi)
# Shows icon based on connection type
# =============================================================================

source "$CONFIG_DIR/colors.sh"

network=(
    icon=$ICON_WIFI
    icon.color=$TEAL
    label=""
    update_freq=10
    script="$CONFIG_DIR/plugins/network.sh"
)

sketchybar --add item network right \
    --set network "${network[@]}" \
    --subscribe network wifi_change system_woke
