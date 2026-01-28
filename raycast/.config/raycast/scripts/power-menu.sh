#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Power Menu
# @raycast.mode silent
# @raycast.icon ⚡
# @raycast.description Quick access to power actions (Lock, Sleep, Restart, Shut Down, Log Out)
# @raycast.author Peter Fodor
# @raycast.authorURL https://github.com/fodurrr

# Show native macOS dialog to pick action
action=$(osascript -e 'choose from list {"🔒 Lock Screen", "😴 Sleep", "🔄 Restart", "⏻ Shut Down", "🚪 Log Out"} with title "Power Menu" with prompt "Choose an action:"')

# Exit if cancelled
[[ "$action" == "false" ]] && exit 0

case "$action" in
    *"Lock"*)
        osascript -e 'tell application "System Events" to keystroke "q" using {command down, control down}'
        ;;
    *"Sleep"*)
        pmset sleepnow
        ;;
    *"Restart"*)
        osascript -e 'tell app "System Events" to restart'
        ;;
    *"Shut Down"*)
        osascript -e 'tell app "System Events" to shut down'
        ;;
    *"Log Out"*)
        osascript -e 'tell app "System Events" to log out'
        ;;
esac
