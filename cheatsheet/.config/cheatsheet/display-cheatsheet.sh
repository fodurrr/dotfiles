#!/bin/bash
# =============================================================================
# Display Cheatsheet
# =============================================================================
# Displays the appropriate cheatsheet based on profile (hacker vs developer).
# Modes: default - floating, centered window
#        tiled   - managed by Aerospace (can be tiled alongside other windows)
# =============================================================================

# Ensure Homebrew and mise tools are in PATH
export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"

MODE="${1:-floating}"

if [[ "$MODE" != "tiled" ]]; then
    # Float this window using Aerospace
    aerospace layout floating 2>/dev/null

    # Resize AND center window using Raycast (requires Raycast Pro subscription)
    # Aerospace cannot center/resize floating windows natively
    open -g 'raycast://customWindowManagementCommand?position=center&absoluteWidth=1120&absoluteHeight=1150' 2>/dev/null
    sleep 0.2
fi

CONFIG_DIR="${HOME}/.config/cheatsheet"

# Detect profile by checking if Aerospace is running
if pgrep -q "AeroSpace"; then
    CHEATSHEET_FILE="${CONFIG_DIR}/keybinds-hacker.md"
else
    CHEATSHEET_FILE="${CONFIG_DIR}/keybinds-developer.md"
fi

# Fallback if specific file doesn't exist
[[ ! -f "$CHEATSHEET_FILE" ]] && CHEATSHEET_FILE="${CONFIG_DIR}/keybinds-hacker.md"

# Convert text escape codes to actual ANSI sequences and display with less
# Only replace [ followed by color codes (0m, 1;33m, 1;35m, 1;36m)
sed -e 's/\[0m/\x1b[0m/g' \
    -e 's/\[1;33m/\x1b[1;33m/g' \
    -e 's/\[1;35m/\x1b[1;35m/g' \
    -e 's/\[1;36m/\x1b[1;36m/g' \
    "$CHEATSHEET_FILE" | less -R
