#!/bin/bash
# =============================================================================
# SketchyBar Help Icon
# =============================================================================
# Centered help icon - click to show keyboard shortcuts cheatsheet
# Click: tiled window (managed by Aerospace)
# Shift-click: floating centered window
# =============================================================================

sketchybar --add item help center \
           --set help \
                 icon="$ICON_HELP" \
                 icon.font="SF Pro:Bold:14.0" \
                 icon.color=$ICON_COLOR \
                 label.drawing=off \
                 background.color=$ITEM_BG_COLOR \
                 background.corner_radius=5 \
                 background.height=24 \
                 background.padding_left=8 \
                 background.padding_right=8 \
                 click_script="if [[ \$MODIFIER == 'shift' ]]; then ~/.config/cheatsheet/show-cheatsheet.sh; else ~/.config/cheatsheet/show-cheatsheet.sh tiled; fi"
