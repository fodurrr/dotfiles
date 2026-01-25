#!/bin/bash
# =============================================================================
# Cheatsheet Launcher
# =============================================================================
# Opens the keyboard shortcuts cheatsheet in a new Ghostty window.
# Used by: Aerospace (alt+?), Sketchybar (? icon click)
# =============================================================================

open -na Ghostty.app --args -e ~/.config/cheatsheet/display-cheatsheet.sh
