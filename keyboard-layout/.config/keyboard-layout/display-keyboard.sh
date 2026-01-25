#!/bin/bash
# =============================================================================
# Display Keyboard Layout
# =============================================================================
# Opens Voyager keyboard layer images in Preview app.
# Modes: "all" - open all 3 layers (default)
#        "cycle" - open layers one at a time
# =============================================================================

CONFIG_DIR="${HOME}/.config/keyboard-layout"
MODE="${1:-all}"

if [[ "$MODE" == "cycle" ]]; then
    # Cycle mode: open one layer at a time
    layer="${2:-1}"
    case "$layer" in
        1|2|3) open "${CONFIG_DIR}/layer-${layer}.png" ;;
        *) open "${CONFIG_DIR}/layer-1.png" ;;
    esac
else
    # All mode: open all 3 layers in Preview
    open "${CONFIG_DIR}/layer-1.png" "${CONFIG_DIR}/layer-2.png" "${CONFIG_DIR}/layer-3.png"
fi
