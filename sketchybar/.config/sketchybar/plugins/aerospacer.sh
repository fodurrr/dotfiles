#!/bin/bash
# =============================================================================
# Aerospace Workspace Highlighter Plugin
# =============================================================================
# Highlights the active workspace in SketchyBar
# =============================================================================

source "$CONFIG_DIR/colors.sh"

# Get the workspace ID from the first argument
WORKSPACE_ID=$1

# Check if this workspace is the focused one
if [ "$FOCUSED_WORKSPACE" = "$WORKSPACE_ID" ]; then
    sketchybar --set $NAME \
        icon.color=$BASE \
        background.color=$HIGHLIGHT
else
    sketchybar --set $NAME \
        icon.color=$TEXT_COLOR \
        background.color=$ITEM_BG_COLOR
fi
