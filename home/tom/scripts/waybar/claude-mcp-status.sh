#!/bin/bash
# Claude MCP server status for waybar

# Check if Claude Desktop is running
claude_running=$(pgrep -f "claude" | wc -l)

if [ "$claude_running" -eq 0 ]; then
    echo '{"text": "🤖 ⏸️", "class": "offline", "tooltip": "Claude Desktop: Not running"}'
    exit 0
fi

# Check Home Assistant MCP server connectivity
ha_status="unknown"
if [ -f "/run/secrets/home_assistant_token" ]; then
    ha_url="https://hass.cassady.house/mcp_server/sse"
    if curl -s --max-time 5 -H "Authorization: Bearer $(cat /run/secrets/home_assistant_token)" "$ha_url" >/dev/null 2>&1; then
        ha_status="healthy"
    else
        ha_status="unreachable"
    fi
else
    ha_status="no-token"
fi

# Check NixOS MCP (this would need to be adapted based on how it's configured)
nixos_mcp_status="unknown"

# Build status
tooltip="Claude Desktop: Running"
class="healthy"
icon="🤖 ✓"

case "$ha_status" in
    "healthy")
        tooltip="$tooltip\nHome Assistant MCP: Connected"
        ;;
    "unreachable")
        tooltip="$tooltip\nHome Assistant MCP: Unreachable"
        class="degraded"
        icon="🤖 ⚠️"
        ;;
    "no-token")
        tooltip="$tooltip\nHome Assistant MCP: No token"
        class="degraded"
        icon="🤖 ⚠️"
        ;;
esac

echo "{\"text\": \"$icon\", \"class\": \"$class\", \"tooltip\": \"$tooltip\"}"
