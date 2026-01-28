#!/bin/bash
# =============================================================================
# Network Plugin
# =============================================================================
# Detects active network interface (Ethernet or WiFi)
# Displays connection status
# =============================================================================

source "$CONFIG_DIR/colors.sh"
source "$CONFIG_DIR/icons.sh"

# Check Ethernet first (en0 is Ethernet on Mac mini)
ETHERNET_STATUS=$(ifconfig en0 2>/dev/null | grep "status: active")

if [ -n "$ETHERNET_STATUS" ]; then
    # Ethernet connected
    ICON=$ICON_ETHERNET
    COLOR=$TEAL
    LABEL="ETH"
else
    # Check WiFi on en1 (Mac mini) by checking interface status
    WIFI_STATUS=$(ifconfig en1 2>/dev/null | grep "status: active")

    if [ -n "$WIFI_STATUS" ]; then
        # WiFi connected - SSID is redacted on macOS Tahoe, so just show "WiFi"
        ICON=$ICON_WIFI
        COLOR=$TEAL
        LABEL="WiFi"
    else
        # No connection
        ICON=$ICON_NETWORK_OFF
        COLOR=$OVERLAY2
        LABEL="Off"
    fi
fi

sketchybar --set $NAME icon="$ICON" icon.color="$COLOR" label="$LABEL"
