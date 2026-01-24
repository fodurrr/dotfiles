#!/bin/bash
# =============================================================================
# Apple Menu Item
# =============================================================================
# Click to show popup with system shortcuts
# =============================================================================

POPUP_OFF="sketchybar --set apple.logo popup.drawing=off"
POPUP_CLICK_SCRIPT="sketchybar --set \$NAME popup.drawing=toggle"

apple_logo=(
    icon=$ICON_APPLE
    icon.font="SF Pro:Black:16.0"
    icon.color=$ACCENT_COLOR
    padding_right=15
    label.drawing=off
    click_script="$POPUP_CLICK_SCRIPT"
    popup.height=35
)

sketchybar --add item apple.logo left \
    --set apple.logo "${apple_logo[@]}"

# Popup items
sketchybar --add item apple.prefs popup.apple.logo \
    --set apple.prefs \
        icon=$ICON_PREFERENCES \
        label="Preferences" \
        click_script="open -a 'System Preferences'; $POPUP_OFF"

sketchybar --add item apple.activity popup.apple.logo \
    --set apple.activity \
        icon=$ICON_ACTIVITY \
        label="Activity" \
        click_script="open -a 'Activity Monitor'; $POPUP_OFF"

sketchybar --add item apple.lock popup.apple.logo \
    --set apple.lock \
        icon=$ICON_LOCK \
        label="Lock Screen" \
        click_script="pmset displaysleepnow; $POPUP_OFF"
