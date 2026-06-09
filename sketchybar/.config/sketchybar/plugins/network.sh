#!/bin/bash
# =============================================================================
# Network Plugin
# =============================================================================
# Detects active network interface (Ethernet or WiFi) via hardware port name,
# so the same script works on MacBook (USB-C hub "USB 10/100/1000 LAN") and
# Mac mini (built-in "Ethernet"). No hardcoded en-numbers.
# =============================================================================

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

# Print BSD device names of all hardware ports whose name matches the given
# awk regex, excluding virtual ports (Thunderbolt Bridge, raw Thunderbolt N).
# Multiple results supported because macOS often exposes phantom "Ethernet
# Adapter (enN)" entries alongside the real interface.
find_devices() {
    local pattern="$1"
    /usr/sbin/networksetup -listallhardwareports 2>/dev/null | awk -v pat="$pattern" '
        /^Hardware Port:/ {
            port = substr($0, index($0, ":") + 2)
            next
        }
        /^Device:/ {
            if (port ~ pat && port !~ /Thunderbolt Bridge/ && port !~ /^Thunderbolt [0-9]/) {
                print $2
            }
        }
    '
}

# Walk Ethernet candidates; first one with status: active wins.
# Phantom "Ethernet Adapter (enN)" entries never go active, so they're skipped.
ETH_ACTIVE=""
for dev in $(find_devices "Ethernet|LAN$"); do
    if ifconfig "$dev" 2>/dev/null | grep -q "status: active"; then
        ETH_ACTIVE="yes"
        break
    fi
done

WIFI_DEV=$(find_devices "^Wi-Fi$" | head -n 1)

if [ -n "$ETH_ACTIVE" ]; then
    ICON=$ICON_ETHERNET
    COLOR=$TEAL
    LABEL="ETH"
else
    WIFI_ACTIVE=""
    if [ -n "$WIFI_DEV" ]; then
        WIFI_ACTIVE=$(ifconfig "$WIFI_DEV" 2>/dev/null | grep "status: active")
    fi

    if [ -n "$WIFI_ACTIVE" ]; then
        ICON=$ICON_WIFI
        COLOR=$TEAL
        LABEL="WiFi"
    else
        ICON=$ICON_NETWORK_OFF
        COLOR=$OVERLAY2
        LABEL="Off"
    fi
fi

sketchybar --set $NAME icon="$ICON" icon.color="$COLOR" label="$LABEL"
