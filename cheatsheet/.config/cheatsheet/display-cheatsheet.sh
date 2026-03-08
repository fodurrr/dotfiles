#!/bin/bash
# =============================================================================
# Display Cheatsheet
# =============================================================================
# Self-focusing: finds own Aerospace window ID via parent PID, brings to front.
# Aerospace on-window-detected rule handles floating.
# Press q to quit.
# =============================================================================

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/bin:/bin:/usr/sbin:$PATH"
export HOME="${HOME:-$(eval echo ~)}"

printf '\033]2;Cheatsheet\007'

# Wait for window to be ready, then bring to front
sleep 1
PPID_VAL=$(ps -o ppid= -p $$ | tr -d " ")
WIN_ID=$(aerospace list-windows --monitor all --pid "$PPID_VAL" 2>/dev/null | head -1 | awk -F'|' '{gsub(/ /,"",$1); print $1}')
[ -n "$WIN_ID" ] && aerospace focus --window-id "$WIN_ID" 2>/dev/null

CONFIG_DIR="${HOME}/.config/cheatsheet"
CHEATSHEET_MODE="${1:-developer}"

case "$CHEATSHEET_MODE" in
    hacker)
        CHEATSHEET_FILE="${CONFIG_DIR}/keybinds-hacker.md"
        ;;
    developer|*)
        CHEATSHEET_FILE="${CONFIG_DIR}/keybinds-developer.md"
        ;;
esac

[[ ! -f "$CHEATSHEET_FILE" ]] && CHEATSHEET_FILE="${CONFIG_DIR}/keybinds-hacker.md"

sed -e 's/\[0m/\x1b[0m/g' \
    -e 's/\[1;33m/\x1b[1;33m/g' \
    -e 's/\[1;35m/\x1b[1;35m/g' \
    -e 's/\[1;36m/\x1b[1;36m/g' \
    "$CHEATSHEET_FILE" | less -R
