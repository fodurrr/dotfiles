#!/bin/bash
# =============================================================================
# Keyboard Layout Viewer Launcher
# =============================================================================
# Opens the Voyager keyboard layout viewer in a new Ghostty window.
# Usage: ./show-keyboard.sh         (show all layers)
#        ./show-keyboard.sh cycle   (cycle through layers)
# Used by: Aerospace (ctrl-alt-k / ctrl-alt-shift-k)
# =============================================================================

open -na Ghostty.app --args -e ~/.config/keyboard-layout/display-keyboard.sh "$@"
