#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Power Menu
# @raycast.mode silent
# @raycast.icon
# @raycast.description Quick access to power actions (Lock, Sleep, Restart, Shut Down, Log Out)
# @raycast.author Peter Fodor
# @raycast.authorURL https://github.com/fodurrr

# @raycast.argument1 { "type": "dropdown", "placeholder": "Action", "data": [ { "title": "Lock Screen", "value": "lock" }, { "title": "Sleep", "value": "sleep" }, { "title": "Restart", "value": "restart" }, { "title": "Shut Down", "value": "shutdown" }, { "title": "Log Out", "value": "logout" } ] }

case "$1" in
    lock)
        /System/Library/CoreServices/Menu\ Extras/User.menu/Contents/Resources/CGSession -suspend
        ;;
    sleep)
        pmset sleepnow
        ;;
    restart)
        osascript -e 'tell app "System Events" to restart'
        ;;
    shutdown)
        osascript -e 'tell app "System Events" to shut down'
        ;;
    logout)
        osascript -e 'tell app "System Events" to log out'
        ;;
esac
