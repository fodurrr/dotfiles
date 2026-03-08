#!/bin/bash
# =============================================================================
# Cheatsheet Launcher
# =============================================================================
# Launches WezTerm, detects the new window, focuses it, and centers it.
# Aerospace auto-floats via on-window-detected rule.
# Used by: Aerospace (alt+?), Sketchybar (click)
# =============================================================================

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/usr/bin:/bin:/usr/sbin:$PATH"

# Snapshot current wezterm-gui window IDs
BEFORE=$(aerospace list-windows --monitor all 2>/dev/null | grep 'wezterm-gui' | awk -F'|' '{gsub(/ /, "", $1); print $1}')

wezterm --config 'initial_cols=109' --config 'initial_rows=50' \
    start -- ~/.config/cheatsheet/display-cheatsheet.sh &

# Detect new window ID
WIN_ID=""
for _ in $(seq 1 15); do
    sleep 0.2
    AFTER=$(aerospace list-windows --monitor all 2>/dev/null | grep 'wezterm-gui' | awk -F'|' '{gsub(/ /, "", $1); print $1}')
    for id in $AFTER; do
        FOUND=0
        for old in $BEFORE; do
            [ "$id" = "$old" ] && FOUND=1 && break
        done
        if [ "$FOUND" = "0" ]; then
            WIN_ID="$id"
            break 2
        fi
    done
done

# Focus the cheatsheet window and center it
if [ -n "$WIN_ID" ]; then
    aerospace focus --window-id "$WIN_ID" 2>/dev/null
    sleep 0.3

    # Center on the screen the window is on
    osascript -e '
    use framework "AppKit"
    tell application "System Events"
        tell application process "wezterm-gui"
            set w to window 1
            set {winW, winH} to size of w
            set {winX, ignore} to position of w
        end tell
    end tell
    set screens to current application'\''s NSScreen'\''s screens()
    set scrW to 5120
    set scrH to 1440
    set scrX to 0
    repeat with s in screens
        set f to s'\''s frame() as list
        set sX to (item 1 of item 1 of f) as integer
        set sW to (item 1 of item 2 of f) as integer
        set sH to (item 2 of item 2 of f) as integer
        if winX >= sX and winX < (sX + sW) then
            set scrX to sX
            set scrW to sW
            set scrH to sH
            exit repeat
        end if
    end repeat
    set barH to 55
    set newX to scrX + ((scrW - winW) / 2) as integer
    set newY to barH + (((scrH - barH) - winH) / 2) as integer
    tell application "System Events"
        tell application process "wezterm-gui"
            set position of window 1 to {newX, newY}
        end tell
    end tell
    ' 2>/dev/null
fi
