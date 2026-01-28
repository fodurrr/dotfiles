#!/bin/bash
# =============================================================================
# SketchyBar Keyboard Layout Icon
# =============================================================================
# Centered keyboard icon in Mauve (#cba6f7)
# Click to show Voyager keyboard layout viewer
# Part of tools_bracket (with help)
# =============================================================================

sketchybar --add item keyboard center \
           --set keyboard \
                 icon="$ICON_KEYBOARD" \
                 icon.font="JetBrainsMono Nerd Font:Bold:14.0" \
                 icon.color=$MAUVE \
                 icon.padding_left=8 \
                 icon.padding_right=8 \
                 label.drawing=off \
                 background.drawing=off \
                 click_script="~/.config/keyboard-layout/show-keyboard.sh"
