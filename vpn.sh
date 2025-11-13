#!/bin/bash

# A script to control a WireGuard VPN connection in Google Cloud Shell.
# Usage: ./vpn.sh on | off | status

# This script is designed to work around Google Cloud Shell's limitations,
# specifically the protected /etc/resolv.conf file.
# For this script to work, you MUST comment out the 'DNS =' line
# in your ~/vpn.conf configuration file.

set -e # Exit immediately if a command fails.

# --- ACTION: ON ---
if [ "$1" = "on" ]; then
    echo "### Starting VPN connection..."

    echo
    echo "--> Step 1: Suppressing apt-get warning for faster execution..."
    # This command prevents the 5-second pause from Cloud Shell's apt-get warning
    mkdir -p ~/.cloudshell && touch ~/.cloudshell/no-apt-get-warning
    echo "    Done."

    echo
    echo "--> Step 2: Updating package lists..."
    sudo apt-get update -y
    echo "    Done."

    echo
    echo "--> Step 3: Ensuring required tools are installed..."
    # 'resolvconf' is needed for DNS management, even if we bypass it.
    # The installation may show non-fatal errors about /etc/resolv.conf, which is expected.
    sudo apt-get install -y wireguard-tools resolvconf
    echo "    Done."

    echo
    echo "--> Step 4: Setting up WireGuard configuration..."
    if [ ! -f ~/vpn.conf ]; then
        echo "    ERROR: Configuration file '~/vpn.conf' not found."
        exit 1
    fi
    # Check if the user has commented out the DNS line as required.
    if grep -qE "^\s*DNS\s*=" ~/vpn.conf; then
        echo "    ------------------------------------------------------------------"
        echo "    WARNING: Your vpn.conf file contains an active 'DNS =' line."
        echo "    This will likely cause the connection to fail in Cloud Shell."
        echo "    Please edit ~/vpn.conf and add a '#' to the beginning of the DNS line."
        echo "    (e.g., #DNS = 1.1.1.1)"
        echo "    ------------------------------------------------------------------"
        sleep 5
    fi
    sudo cp ~/vpn.conf /etc/wireguard/wg0.conf
    sudo chmod 600 /etc/wireguard/wg0.conf
    echo "    Configuration file '/etc/wireguard/wg0.conf' is ready."

    echo
    echo "--> Step 5: Activating the VPN tunnel..."
    sudo wg-quick up wg0
    echo "    Done."

    echo
    echo "--> Step 6: Verifying connection..."
    sudo wg show
    echo "    Verification complete. Look for 'latest handshake' and 'transfer' data above."

    echo
    echo "### VPN connection script finished. ###"
    echo "To check status later, run: ./vpn.sh status"
    echo "To disconnect, run: ./vpn.sh off"

# --- ACTION: OFF ---
elif [ "$1" = "off" ]; then
    echo "### Stopping VPN connection and cleaning up..."
    if ip link show wg0 &> /dev/null; then
        sudo wg-quick down wg0
        echo "    VPN connection is now OFF."
    else
        echo "    VPN connection was not active."
    fi

    # --- FINAL SECURITY CLEANUP ---
    # Securely delete the operational config file so no valid key is left behind.
    if [ -f /etc/wireguard/wg0.conf ]; then
        sudo rm /etc/wireguard/wg0.conf
        echo "    Operational config file has been securely deleted."
    fi

# --- ACTION: STATUS ---
elif [ "$1" = "status" ]; then
    echo "### Checking WireGuard status..."
    if ! sudo wg show; then
        echo "No active WireGuard interface found."
    fi

# --- INVALID ARGUMENT ---
else
    echo "Usage: $0 [on|off|status]"
    exit 1
fi
