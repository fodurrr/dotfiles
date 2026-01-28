#!/bin/bash
# =============================================================================
# Lock Screen Item
# =============================================================================
# Click to lock screen instantly
# Displayed in center section, left of workspaces
# =============================================================================

lock=(
    icon=$ICON_LOCK
    icon.font="JetBrainsMono Nerd Font:Bold:14.0"
    icon.color=$YELLOW
    icon.padding_left=8
    icon.padding_right=8
    label.drawing=off
    background.color=$ITEM_BG_COLOR
    background.corner_radius=5
    background.height=24
    background.drawing=on
    click_script="pmset displaysleepnow"
)

sketchybar --add item lock center \
    --set lock "${lock[@]}"

# Bracket around lock (consistent with other center brackets)
sketchybar --add bracket lock_bracket lock \
    --set lock_bracket \
        background.color=$SURFACE0 \
        background.corner_radius=5 \
        background.height=28
