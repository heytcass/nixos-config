#!/bin/bash
# Dock detection status for waybar (Niri/transporter)

# Check for dock detection log
dock_log="$HOME/.local/share/dock-events.log"
monitor_count=$(niri msg outputs | jq '. | length' 2>/dev/null || echo "1")

# Check for USB dock (Foxconn/Hon Hai: 0489:e0a2)
usb_dock=$(lsusb | grep -i "0489:e0a2" | wc -l)

# Check for Thunderbolt dock (Intel: 8086:15d3)  
tb_dock=$(lspci | grep -i "15d3" | wc -l)

# Determine dock status
dock_connected=false
dock_type="none"

if [ "$usb_dock" -gt 0 ]; then
    dock_connected=true
    dock_type="USB"
elif [ "$tb_dock" -gt 0 ]; then
    dock_connected=true
    dock_type="Thunderbolt"
fi

# Build status
if [ "$dock_connected" = true ]; then
    if [ "$monitor_count" -gt 1 ]; then
        echo "{\"text\": \"🖥️ $monitor_count\", \"class\": \"dock-connected\", \"tooltip\": \"Dock: $dock_type connected\\nMonitors: $monitor_count\"}"
    else
        echo "{\"text\": \"🔌 ⚠️\", \"class\": \"dock-connected-no-displays\", \"tooltip\": \"Dock: $dock_type connected\\nMonitors: $monitor_count (external displays not detected)\"}"
    fi
else
    echo "{\"text\": \"💻 $monitor_count\", \"class\": \"laptop-only\", \"tooltip\": \"Laptop mode\\nMonitors: $monitor_count\"}"
fi