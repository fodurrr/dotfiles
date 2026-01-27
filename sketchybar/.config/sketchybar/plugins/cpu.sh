#!/bin/bash
# =============================================================================
# CPU Plugin
# =============================================================================
# Processes CPU usage from sketchybar-system-stats events
# Color-coded: green (low) -> peach (medium) -> red (high)
# =============================================================================

source "$CONFIG_DIR/colors.sh"

# Get CPU usage - prefer event data, fallback to system query
if [ -n "$CPU_USAGE" ]; then
    CPU="$CPU_USAGE"
else
    # Fallback: Get CPU usage via top
    CPU=$(top -l 1 -n 0 | grep "CPU usage" | awk '{print int($3)}')
fi

# Determine color based on usage
if [ "$CPU" -lt 30 ]; then
    COLOR=$GREEN
elif [ "$CPU" -lt 70 ]; then
    COLOR=$PEACH
else
    COLOR=$RED
fi

sketchybar --set $NAME label="${CPU}%" icon.color="$COLOR"
