#!/bin/bash
# =============================================================================
# SketchyBar Help Icon
# =============================================================================
# Centered book icon in Peach (#fab387)
# Click: tiled cheatsheet (managed by Aerospace)
# Ctrl+click: centered cheatsheet (floating)
# =============================================================================

sketchybar --add item help center \
           --set help \
                 icon="$ICON_HELP" \
                 icon.font="JetBrainsMono Nerd Font:Bold:14.0" \
                 icon.color=$PEACH \
                 label.drawing=off \
                 background.color=$ITEM_BG_COLOR \
                 background.corner_radius=5 \
                 background.height=24 \
                 background.padding_left=8 \
                 background.padding_right=8 \
                 click_script="if [[ \$MODIFIER == 'ctrl' ]]; then ~/.config/cheatsheet/show-cheatsheet.sh; else ~/.config/cheatsheet/show-cheatsheet.sh tiled; fi"
