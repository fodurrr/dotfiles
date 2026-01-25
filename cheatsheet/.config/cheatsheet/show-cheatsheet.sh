#!/bin/bash
# =============================================================================
# Cheatsheet Launcher
# =============================================================================
# Opens the keyboard shortcuts cheatsheet in a new Ghostty window.
# Usage: ./show-cheatsheet.sh         (floating, centered)
#        ./show-cheatsheet.sh tiled   (tiled, managed by Aerospace)
# Used by: Aerospace (alt+?), Sketchybar (? icon click)
# =============================================================================

open -na Ghostty.app --args -e ~/.config/cheatsheet/display-cheatsheet.sh "$@"
