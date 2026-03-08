#!/bin/bash
# =============================================================================
# Display Cheatsheet
# =============================================================================
# Just displays the cheatsheet. Floating/positioning handled by launcher.
# Press q to quit.
# =============================================================================

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/bin:/bin:/usr/sbin:$PATH"

printf '\033]2;Cheatsheet\007'

CONFIG_DIR="${HOME}/.config/cheatsheet"

if pgrep -q "AeroSpace"; then
    CHEATSHEET_FILE="${CONFIG_DIR}/keybinds-hacker.md"
else
    CHEATSHEET_FILE="${CONFIG_DIR}/keybinds-developer.md"
fi

[[ ! -f "$CHEATSHEET_FILE" ]] && CHEATSHEET_FILE="${CONFIG_DIR}/keybinds-hacker.md"

sed -e 's/\[0m/\x1b[0m/g' \
    -e 's/\[1;33m/\x1b[1;33m/g' \
    -e 's/\[1;35m/\x1b[1;35m/g' \
    -e 's/\[1;36m/\x1b[1;36m/g' \
    "$CHEATSHEET_FILE" | less -R
