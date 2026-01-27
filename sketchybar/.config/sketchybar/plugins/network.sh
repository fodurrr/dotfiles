#!/bin/bash
# =============================================================================
# Network Plugin
# =============================================================================
# Detects active network interface (Ethernet or WiFi)
# Displays connection status
# =============================================================================

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

# Check Ethernet first (en0 is usually Ethernet on Mac mini, en1 on MacBooks with dongle)
ETHERNET_STATUS=$(ifconfig en0 2>/dev/null | grep "status: active")

if [ -n "$ETHERNET_STATUS" ]; then
    # Ethernet connected
    ICON=$ICON_ETHERNET
    COLOR=$TEAL
    LABEL="ETH"
else
    # Check WiFi (usually en0 on MacBook, en1 on Mac mini)
    # Try to get WiFi info from networksetup
    WIFI_SSID=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I 2>/dev/null | grep " SSID" | awk '{print $2}')

    if [ -n "$WIFI_SSID" ]; then
        # WiFi connected
        ICON=$ICON_WIFI
        COLOR=$TEAL
        # Truncate SSID if too long
        if [ ${#WIFI_SSID} -gt 10 ]; then
            LABEL="${WIFI_SSID:0:8}.."
        else
            LABEL="$WIFI_SSID"
        fi
    else
        # No connection
        ICON=$ICON_NETWORK_OFF
        COLOR=$OVERLAY2
        LABEL="Off"
    fi
fi

sketchybar --set $NAME icon="$ICON" icon.color="$COLOR" label="$LABEL"
