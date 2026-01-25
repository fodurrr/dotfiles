#!/bin/bash
# =============================================================================
# Display Keyboard Layout
# =============================================================================
# Displays Voyager keyboard layers using chafa (terminal image viewer).
# Modes: "all" - show all 3 layers stacked (default)
#        "cycle" - cycle through layers one at a time
# Window is managed by Aerospace (can be tiled alongside other windows).
# =============================================================================

# Ensure Homebrew tools are in PATH
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

CONFIG_DIR="${HOME}/.config/keyboard-layout"
MODE="${1:-all}"

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

        chafa "${CONFIG_DIR}/layer-${layer_num}.png"

        read -rsn1 key
        case "$key" in
            q|Q) exit 0 ;;
            p|P) current=$(( (current - 1 + total) % total )) ;;
            *) current=$(( (current + 1) % total )) ;;
        esac
    done
else
    # All mode: show all layers stacked vertically
    # Display directly (no pipe) so chafa graphics render properly
    # Press q to quit, scroll with terminal
    clear
    echo ""
    echo "  Voyager Keyboard Layout - All Layers  [q=quit]"
    echo ""

    for i in 1 2 3; do
        case $i in
            1) layer_name="Main" ;;
            2) layer_name="Code" ;;
            3) layer_name="NumPad" ;;
        esac

        echo "  ═══ Layer ${i}: ${layer_name} ═══"
        echo ""
        chafa "${CONFIG_DIR}/layer-${i}.png"
        echo ""
    done

    # Wait for q to quit
    while true; do
        read -rsn1 key
        case "$key" in
            q|Q) exit 0 ;;
        esac
    done
fi
