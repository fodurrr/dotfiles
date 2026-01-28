#!/bin/bash
# =============================================================================
# Battery Plugin
# =============================================================================
# Displays battery status, auto-hides if no battery detected
# =============================================================================

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

# Check if battery exists
BATTERY_INFO=$(pmset -g batt)

if ! echo "$BATTERY_INFO" | grep -qE '[0-9]+%'; then
    # No battery - hide the item
    sketchybar --set $NAME drawing=off
    exit 0
fi

# Show the item (in case it was previously hidden)
sketchybar --set $NAME drawing=on

# Get battery percentage
PERCENTAGE=$(echo "$BATTERY_INFO" | grep -o '[0-9]*%' | head -1 | tr -d '%')

# Check if charging
CHARGING=$(echo "$BATTERY_INFO" | grep -c "AC Power")

# Determine icon and color based on level
if [ "$CHARGING" -gt 0 ]; then
    ICON=$ICON_BATTERY_CHARGING
    COLOR=$GREEN
elif [ "$PERCENTAGE" -gt 75 ]; then
    ICON=$ICON_BATTERY
    COLOR=$GREEN
elif [ "$PERCENTAGE" -gt 50 ]; then
    ICON=$ICON_BATTERY_75
    COLOR=$GREEN
elif [ "$PERCENTAGE" -gt 25 ]; then
    ICON=$ICON_BATTERY_50
    COLOR=$PEACH
elif [ "$PERCENTAGE" -gt 10 ]; then
    ICON=$ICON_BATTERY_25
    COLOR=$PEACH
else
    ICON=$ICON_BATTERY_0
    COLOR=$RED
fi

sketchybar --set $NAME icon="$ICON" icon.color="$COLOR" label="${PERCENTAGE}%"
