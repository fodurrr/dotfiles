#!/bin/bash
# =============================================================================
# Calendar Plugin
# =============================================================================
# Updates the calendar item with current date and time
# Format: Mon 27 Jan  14:30 (with clock icon as separator)
# =============================================================================

source "$CONFIG_DIR/icons.sh"

DATE_PART=$(date '+%a %d %b')
TIME_PART=$(date '+%H:%M')
sketchybar --set $NAME label="$DATE_PART $ICON_CLOCK $TIME_PART"
