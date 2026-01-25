#!/bin/bash
# =============================================================================
# Cheatsheet Launcher
# =============================================================================
# Opens the keyboard shortcuts cheatsheet in a new Ghostty window.
# Usage: ./show-cheatsheet.sh tiled   (tiled, managed by Aerospace)
#        ./show-cheatsheet.sh         (floating, centered)
# Used by: Aerospace (alt+/ = tiled, alt+? = centered), Sketchybar (click/shift-click)
# =============================================================================

open -na Ghostty.app --args -e ~/.config/cheatsheet/display-cheatsheet.sh "$@"
