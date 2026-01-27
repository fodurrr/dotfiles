#!/bin/bash
# =============================================================================
# SketchyBar Keyboard Layout Icon
# =============================================================================
# Centered keyboard icon in Mauve (#cba6f7)
# Click to show Voyager keyboard layout viewer
# =============================================================================

sketchybar --add item keyboard center \
           --set keyboard \
                 icon="$ICON_KEYBOARD" \
                 icon.font="JetBrainsMono Nerd Font:Bold:14.0" \
                 icon.color=$MAUVE \
                 label.drawing=off \
                 background.color=$ITEM_BG_COLOR \
                 background.corner_radius=5 \
                 background.height=24 \
                 background.padding_left=8 \
                 background.padding_right=8 \
                 click_script="~/.config/keyboard-layout/show-keyboard.sh"
