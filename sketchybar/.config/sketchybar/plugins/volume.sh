#!/bin/bash
# =============================================================================
# Volume Plugin
# =============================================================================
# Controls and displays system volume
# Click to toggle mute, scroll to adjust
# =============================================================================

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

# Handle toggle mute command
if [ "$1" = "toggle" ]; then
    osascript -e "set volume output muted not (output muted of (get volume settings))"
fi

# Handle scroll events
if [ "$SENDER" = "mouse.scrolled.global" ]; then
    CURRENT=$(osascript -e "output volume of (get volume settings)")
    if [ "$SCROLL_DELTA" -gt 0 ]; then
        NEW=$((CURRENT + 5))
        [ "$NEW" -gt 100 ] && NEW=100
    else
        NEW=$((CURRENT - 5))
        [ "$NEW" -lt 0 ] && NEW=0
    fi
    osascript -e "set volume output volume $NEW"
fi

# Get current volume state
VOLUME=$(osascript -e "output volume of (get volume settings)")
MUTED=$(osascript -e "output muted of (get volume settings)")

# Set icon based on volume level
if [ "$MUTED" = "true" ] || [ "$VOLUME" -eq 0 ]; then
    ICON=$ICON_VOLUME_MUTE
    COLOR=$OVERLAY2
elif [ "$VOLUME" -lt 30 ]; then
    ICON=$ICON_VOLUME_LOW
    COLOR=$SKY
else
    ICON=$ICON_VOLUME
    COLOR=$SKY
fi

sketchybar --set $NAME icon="$ICON" icon.color="$COLOR" label="${VOLUME}%"
