#!/bin/bash
# =============================================================================
# SketchyBar Help Icon
# =============================================================================
# Centered book icon in Peach (#fab387)
# Click: tiled cheatsheet (managed by Aerospace)
# Ctrl+click: centered cheatsheet (floating)
# Part of tools_bracket (with keyboard)
# =============================================================================

sketchybar --add item help center \
           --set help \
                 icon="$ICON_HELP" \
                 icon.font="JetBrainsMono Nerd Font:Bold:14.0" \
                 icon.color=$PEACH \
                 icon.padding_left=8 \
                 icon.padding_right=8 \
                 label.drawing=off \
                 background.drawing=off \
                 click_script="if [[ \$MODIFIER == 'ctrl' ]]; then ~/.config/cheatsheet/show-cheatsheet.sh; else ~/.config/cheatsheet/show-cheatsheet.sh tiled; fi"
