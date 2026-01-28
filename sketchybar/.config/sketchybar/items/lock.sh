#!/bin/bash
# =============================================================================
# Lock Screen Item
# =============================================================================
# Click to lock screen instantly
# Displayed in center section, left of workspaces
# =============================================================================

lock=(
    icon=$ICON_LOCK
    icon.font="JetBrainsMono Nerd Font:Bold:16.0"
    icon.color=$YELLOW
    label.drawing=off
    padding_right=20
    click_script="pmset displaysleepnow"
)

sketchybar --add item lock center \
    --set lock "${lock[@]}"
