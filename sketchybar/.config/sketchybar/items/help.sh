#!/bin/bash
# =============================================================================
# SketchyBar Help Icon
# =============================================================================
# Click: tiled cheatsheet (managed by Aerospace)
# Ctrl+click: centered cheatsheet (floating)
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
                 click_script="if [[ \$MODIFIER == 'ctrl' ]]; then ~/.config/cheatsheet/show-cheatsheet.sh; else ~/.config/cheatsheet/show-cheatsheet.sh tiled; fi"
