#!/bin/bash
# =============================================================================
# Memory Plugin
# =============================================================================
# Processes RAM usage from sketchybar-system-stats events
# Color-coded: green (low) -> peach (medium) -> red (high)
# =============================================================================

source "$CONFIG_DIR/colors.sh"

# Get memory usage - prefer event data, fallback to system query
if [ -n "$RAM_USAGE" ]; then
    MEM="$RAM_USAGE"
else
    # Fallback: Calculate memory usage from vm_stat
    PAGES_FREE=$(vm_stat | grep "Pages free" | awk '{print $3}' | tr -d '.')
    PAGES_ACTIVE=$(vm_stat | grep "Pages active" | awk '{print $3}' | tr -d '.')
    PAGES_INACTIVE=$(vm_stat | grep "Pages inactive" | awk '{print $3}' | tr -d '.')
    PAGES_SPECULATIVE=$(vm_stat | grep "Pages speculative" | awk '{print $3}' | tr -d '.')
    PAGES_WIRED=$(vm_stat | grep "Pages wired" | awk '{print $4}' | tr -d '.')

    # Calculate used percentage (wired + active as "used")
    TOTAL=$((PAGES_FREE + PAGES_ACTIVE + PAGES_INACTIVE + PAGES_SPECULATIVE + PAGES_WIRED))
    USED=$((PAGES_WIRED + PAGES_ACTIVE))

    if [ "$TOTAL" -gt 0 ]; then
        MEM=$((USED * 100 / TOTAL))
    else
        MEM=0
    fi
fi

# Determine color based on usage
if [ "$MEM" -lt 50 ]; then
    COLOR=$GREEN
elif [ "$MEM" -lt 80 ]; then
    COLOR=$PEACH
else
    COLOR=$RED
fi

sketchybar --set $NAME label="${MEM}%" icon.color="$COLOR"
