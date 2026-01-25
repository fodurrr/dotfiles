#!/bin/bash
# =============================================================================
# SketchyBar Cheatsheet Trigger
# =============================================================================
# Handles both cold-start and running Ghostty cases:
# - Ghostty running: Use Raycast deeplink (has accessibility permissions)
# - Ghostty NOT running: Launch directly with open -na (no permissions needed)
# =============================================================================

DISPLAY_SCRIPT="$HOME/.config/cheatsheet/display-cheatsheet.sh"

if pgrep -q "Ghostty"; then
    # Ghostty running: use Raycast deeplink (works via AppleScript with permissions)
    open -g 'raycast://script-commands/show-cheatsheet'
else
    # Ghostty NOT running: launch directly with command (no permissions needed)
    open -na Ghostty.app --args -e "$DISPLAY_SCRIPT"
fi
