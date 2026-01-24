#!/bin/bash
# =============================================================================
# Aerospace Workspaces Item
# =============================================================================
# Displays workspace indicators that sync with Aerospace
# Click to switch workspaces
# =============================================================================

WORKSPACES=(1 2 3 4 5)

for sid in "${WORKSPACES[@]}"; do
    sketchybar --add item space.$sid left \
        --subscribe space.$sid aerospace_workspace_change \
        --set space.$sid \
            icon="$sid" \
            icon.font="SF Pro:Bold:12.0" \
            icon.padding_left=8 \
            icon.padding_right=8 \
            background.color=$ITEM_BG_COLOR \
            background.corner_radius=5 \
            background.height=24 \
            background.drawing=on \
            label.drawing=off \
            click_script="aerospace workspace $sid" \
            script="$CONFIG_DIR/plugins/aerospacer.sh $sid"
done

# Add a bracket around workspaces
sketchybar --add bracket spaces '/space\..*/' \
    --set spaces \
        background.color=$SURFACE0 \
        background.corner_radius=5 \
        background.height=28
