#!/bin/bash
# =============================================================================
# Keyboard Layout Viewer
# =============================================================================
# Opens Voyager keyboard layer images in Preview app.
# Usage: ./show-keyboard.sh         (show all layers)
#        ./show-keyboard.sh cycle   (cycle through layers one at a time)
# Used by: Aerospace (alt-; / alt-shift-;)
# =============================================================================

CONFIG_DIR="${HOME}/.config/keyboard-layout"

if [[ "$1" == "cycle" ]]; then
    # Cycle mode: open layers one at a time
    layer="${2:-1}"
    case "$layer" in
        1|2|3) open "${CONFIG_DIR}/layer-${layer}.png" ;;
        *) open "${CONFIG_DIR}/layer-1.png" ;;
    esac
else
    # All mode: open all 3 layers in Preview
    open "${CONFIG_DIR}/layer-1.png" "${CONFIG_DIR}/layer-2.png" "${CONFIG_DIR}/layer-3.png"
fi
