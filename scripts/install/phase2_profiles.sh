#!/bin/bash

# =============================================================================
# PHASE 2: PROFILE SELECTION
# =============================================================================
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Phase 2: Profile Selection"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

# Interactive profile selection
if [[ "$INTERACTIVE" == true && ${#SELECTED_PROFILES[@]} -eq 0 ]]; then
    echo ""
    echo "Select one or more profiles (SPACE to select, ENTER to confirm):"
    echo ""

    # Get profiles into array (compatible with bash 3.x)
    AVAILABLE_PROFILES=()
    while IFS= read -r line; do
        AVAILABLE_PROFILES+=("$line")
    done < <(get_profiles)

    # Add extras option at the end
    AVAILABLE_PROFILES+=("➕ Install individual apps")

    if command -v gum &> /dev/null; then
        # Use gum for interactive selection (minimal pre-selected)
        while IFS= read -r line; do
            [[ -n "$line" ]] && SELECTED_PROFILES+=("$line")
        done < <(gum choose --no-limit \
            --header "Which profiles do you want to install? (SPACE to toggle, ENTER to confirm)" \
            --cursor-prefix "[ ] " \
            --selected-prefix "[x] " \
            --selected="minimal" \
            "${AVAILABLE_PROFILES[@]}")
    else
        # Fallback to simple select
        echo "Available profiles:"
        select profile in "${AVAILABLE_PROFILES[@]}" "Done"; do
            if [[ "$profile" == "Done" ]]; then
                break
            fi
            SELECTED_PROFILES+=("$profile")
            echo "Selected: ${SELECTED_PROFILES[*]}"
        done
    fi

    # Check if user selected "Install individual apps"
    if [[ " ${SELECTED_PROFILES[*]} " == *"➕ Install individual apps"* ]]; then
        EXTRAS_MODE=true
        SELECTED_PROFILES=()  # Clear - not installing profiles
    fi

    if [[ ${#SELECTED_PROFILES[@]} -eq 0 && "$EXTRAS_MODE" != true ]]; then
        echo "No profiles selected. Using default: minimal"
        SELECTED_PROFILES=("minimal")
    fi

    # Show summary (skip for extras mode)
    if [[ "$EXTRAS_MODE" != true ]]; then
        echo ""
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "  Installation Summary"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo ""
        echo "Selected profiles: ${SELECTED_PROFILES[*]}"
        echo ""

        # Confirm
        if command -v gum &> /dev/null; then
            gum confirm "Proceed with installation?" || exit 0
        else
            read -p "Proceed? (y/n) " -n 1 -r
            echo
            [[ ! $REPLY =~ ^[Yy]$ ]] && exit 0
        fi
    fi
fi

# Default to minimal if nothing selected (skip for extras mode)
if [[ ${#SELECTED_PROFILES[@]} -eq 0 && "$EXTRAS_MODE" != true ]]; then
    SELECTED_PROFILES=("minimal")
fi
