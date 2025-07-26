#!/bin/bash
# Tailscale VPN status for waybar

# Check if tailscale is installed and accessible
if ! command -v tailscale >/dev/null 2>&1; then
    echo '{"text": "", "class": "not-installed", "tooltip": "Tailscale not found"}'
    exit 0
fi

# Get tailscale status
status=$(tailscale status --json 2>/dev/null)

if [ $? -ne 0 ]; then
    echo '{"text": "🔗 ❌", "class": "disconnected", "tooltip": "Tailscale: Disconnected"}'
    exit 0
fi

# Parse status
backend_state=$(echo "$status" | jq -r '.BackendState // "Unknown"')
self_ip=$(echo "$status" | jq -r '.Self.TailscaleIPs[0] // "unknown"')
peer_count=$(echo "$status" | jq '.Peers | length')
exit_node=$(echo "$status" | jq -r '.ExitNodeStatus.TailscaleIPs[0] // "none"')

# Build tooltip
tooltip="Tailscale: ${backend_state}"
if [ "$backend_state" = "Running" ]; then
    tooltip="$tooltip\nIP: $self_ip"
    tooltip="$tooltip\nPeers: $peer_count"
    if [ "$exit_node" != "none" ]; then
        tooltip="$tooltip\nExit Node: $exit_node"
    fi
fi

# Determine icon and class
case "$backend_state" in
    "Running")
        if [ "$peer_count" -gt 0 ]; then
            echo "{\"text\": \"🔗 $peer_count\", \"class\": \"connected\", \"tooltip\": \"$tooltip\"}"
        else
            echo "{\"text\": \"🔗 ⚠️\", \"class\": \"connected-no-peers\", \"tooltip\": \"$tooltip\"}"
        fi
        ;;
    "Stopped")
        echo '{"text": "🔗 ⏸️", "class": "stopped", "tooltip": "Tailscale: Stopped"}'
        ;;
    *)
        echo "{\"text\": \"🔗 ❓\", \"class\": \"unknown\", \"tooltip\": \"Tailscale: $backend_state\"}"
        ;;
esac
