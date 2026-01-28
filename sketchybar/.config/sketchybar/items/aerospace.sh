#!/bin/bash
# =============================================================================
# Aerospace Workspaces Item
# =============================================================================
# Displays workspace indicators 1-3 in center
# Click to switch workspaces
# =============================================================================

WORKSPACES=(1 2 3)

for sid in "${WORKSPACES[@]}"; do
    # Add extra padding_left to first workspace for gap after lock bracket
    if [ "$sid" = "1" ]; then
        EXTRA_PADDING="padding_left=10"
    else
        EXTRA_PADDING=""
    fi

    sketchybar --add item space.$sid center \
        --subscribe space.$sid aerospace_workspace_change \
        --set space.$sid \
            icon="$sid" \
            icon.font="JetBrainsMono Nerd Font:Bold:12.0" \
            icon.padding_left=8 \
            icon.padding_right=8 \
            background.color=$ITEM_BG_COLOR \
            background.corner_radius=5 \
            background.height=24 \
            background.drawing=on \
            label.drawing=off \
            click_script="aerospace workspace $sid" \
            script="$CONFIG_DIR/plugins/aerospacer.sh $sid" \
            $EXTRA_PADDING
done

# Add a bracket around workspaces
sketchybar --add bracket spaces '/space\..*/' \
    --set spaces \
        background.color=$SURFACE0 \
        background.corner_radius=5 \
        background.height=28
