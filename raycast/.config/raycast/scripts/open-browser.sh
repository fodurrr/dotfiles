#!/bin/bash

# Required parameters:
# @raycast.schemaVersion 1
# @raycast.title Open Browser
# @raycast.mode silent
# @raycast.icon
# @raycast.description Open default browser (Firefox)
# @raycast.author Peter Fodor
# @raycast.authorURL https://github.com/fodurrr

# Try to get default browser, fallback to Firefox
default_browser=$(defaults read ~/Library/Preferences/com.apple.LaunchServices/com.apple.launchservices.secure LSHandlers 2>/dev/null | grep -A2 'https' | grep 'LSHandlerRoleAll' | head -1 | sed 's/.*= "\(.*\)";/\1/')

if [[ -n "$default_browser" ]]; then
    open -b "$default_browser"
else
    open -a "Firefox"
fi
