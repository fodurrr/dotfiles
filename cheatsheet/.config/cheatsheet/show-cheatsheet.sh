#!/bin/bash
# =============================================================================
# Cheatsheet Launcher (thin wrapper)
# =============================================================================
# Launches WezTerm with the cheatsheet. Aerospace auto-floats via rule.
# display-cheatsheet.sh self-focuses via PID.
# Used by: Aerospace (alt+?), Sketchybar (click)
# =============================================================================

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/bin:/bin:/usr/sbin:$PATH"

CHEATSHEET_MODE="developer"
if command -v aerospace >/dev/null 2>&1 && [[ -f "${HOME}/.config/aerospace/aerospace.toml" ]]; then
    CHEATSHEET_MODE="hacker"
fi

wezterm --config 'initial_cols=109' --config 'initial_rows=50' \
    start --position 'active:2000,135' -- ~/.config/cheatsheet/display-cheatsheet.sh "$CHEATSHEET_MODE"
