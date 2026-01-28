#!/bin/bash
# =============================================================================
# Calendar/Clock Items
# =============================================================================
# Displays date and time as two separate items for better styling
# Date: calendar icon + Mon 28 Jan
# Time: clock icon + 14:30
# =============================================================================

# Time item (added first = rightmost)
time_item=(
    icon=$ICON_CLOCK
    icon.color=$SKY
    icon.padding_left=8
    icon.padding_right=4
    label.padding_right=8
    update_freq=30
    script="$CONFIG_DIR/plugins/time.sh"
    background.drawing=off
)

sketchybar --add item time_item right \
    --set time_item "${time_item[@]}"

# Date item (added second = left of time)
date_item=(
    icon=$ICON_CALENDAR
    icon.color=$ACCENT_COLOR
    icon.padding_left=8
    icon.padding_right=4
    label.padding_right=4
    update_freq=60
    script="$CONFIG_DIR/plugins/date.sh"
    click_script="$CONFIG_DIR/plugins/calendar_click.sh"
    background.drawing=off
)

sketchybar --add item date_item right \
    --set date_item "${date_item[@]}"

# Bracket around date and time
sketchybar --add bracket calendar_bracket date_item time_item \
    --set calendar_bracket \
        background.color=$SURFACE0 \
        background.corner_radius=5 \
        background.height=28
