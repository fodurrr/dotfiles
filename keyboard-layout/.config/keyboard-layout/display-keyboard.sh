#!/bin/bash
# =============================================================================
# Display Keyboard Layout
# =============================================================================
# Displays Voyager keyboard layers using chafa (terminal image viewer).
# Modes: "all" - show all 3 layers stacked (default)
#        "cycle" - cycle through layers one at a time
# Floats, resizes, and centers window using Aerospace + Raycast.
# =============================================================================

# Ensure Homebrew tools are in PATH
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

# Float this window using Aerospace
aerospace layout floating 2>/dev/null

# Resize AND center window using Raycast (requires Raycast Pro subscription)
open -g 'raycast://customWindowManagementCommand?position=center&absoluteWidth=900&absoluteHeight=1000' 2>/dev/null
sleep 0.2

CONFIG_DIR="${HOME}/.config/keyboard-layout"
MODE="${1:-all}"

# Layer names for display
LAYER_NAMES="Main Code NumPad"

if [[ "$MODE" == "cycle" ]]; then
    # Cycle mode: show one layer at a time
    current=0
    total=3

    while true; do
        clear
        layer_num=$((current + 1))

        # Get layer name (bash 3.2 compatible)
        case $current in
            0) layer_name="Main" ;;
            1) layer_name="Code" ;;
            2) layer_name="NumPad" ;;
        esac

        echo ""
        echo "  Voyager Keyboard - Layer ${layer_num}: ${layer_name}  [SPACE/n=next, p=prev, q=quit]"
        echo ""

        chafa --size=80x40 "${CONFIG_DIR}/layer-${layer_num}.png"

        read -rsn1 key
        case "$key" in
            q|Q) exit 0 ;;
            p|P) current=$(( (current - 1 + total) % total )) ;;
            *) current=$(( (current + 1) % total )) ;;
        esac
    done
else
    # All mode: show all layers stacked vertically
    clear
    {
        echo ""
        echo "  Voyager Keyboard Layout - All Layers  [q=quit]"
        echo ""

        for i in 1 2 3; do
            case $i in
                1) layer_name="Main" ;;
                2) layer_name="Code" ;;
                3) layer_name="NumPad" ;;
            esac

            echo "  ═══════════════════════════════════════════════════════════════════════════"
            echo "  Layer ${i}: ${layer_name}"
            echo "  ═══════════════════════════════════════════════════════════════════════════"
            echo ""
            chafa --size=80x25 "${CONFIG_DIR}/layer-${i}.png"
            echo ""
        done
    } | less -R
fi
