#!/bin/bash
# Container status for waybar (Hyprland/gti)

# Check if podman is available
if ! command -v podman >/dev/null 2>&1; then
    echo '{"text": "", "class": "not-available", "tooltip": "Podman not found"}'
    exit 0
fi

# Get container status
running_containers=$(podman ps --format "{{.Names}}" 2>/dev/null | wc -l)
total_containers=$(podman ps -a --format "{{.Names}}" 2>/dev/null | wc -l)

# Build status
if [ "$running_containers" -eq 0 ]; then
    if [ "$total_containers" -eq 0 ]; then
        echo '{"text": "", "class": "none", "tooltip": "No containers"}'
    else
        echo "{\"text\": \"📦 ⏸️\", \"class\": \"stopped\", \"tooltip\": \"Containers: $total_containers total, none running\"}"
    fi
else
    if [ "$running_containers" -eq 1 ]; then
        container_name=$(podman ps --format "{{.Names}}" 2>/dev/null | head -1)
        echo "{\"text\": \"📦 $running_containers\", \"class\": \"running\", \"tooltip\": \"Containers: $running_containers running ($container_name)\"}"
    else
        echo "{\"text\": \"📦 $running_containers\", \"class\": \"running\", \"tooltip\": \"Containers: $running_containers running, $total_containers total\"}"
    fi
fi