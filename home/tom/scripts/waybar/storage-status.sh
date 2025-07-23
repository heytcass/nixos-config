#!/bin/bash
# Storage status for waybar (Niri/transporter with Btrfs)

# Check if btrfs is available
if ! command -v btrfs >/dev/null 2>&1; then
    echo '{"text": "", "class": "not-available", "tooltip": "Btrfs not found"}'
    exit 0
fi

# Get filesystem usage for root
root_usage=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
root_used=$(df -h / | awk 'NR==2 {print $3}')
root_total=$(df -h / | awk 'NR==2 {print $2}')

# Check if root is btrfs
is_btrfs=$(findmnt -n -o FSTYPE / | grep -q btrfs && echo "true" || echo "false")

# Get compression info if btrfs
compression_info=""
if [ "$is_btrfs" = "true" ]; then
    compression_info="(Btrfs + zstd)"
fi

# Determine status class
class="normal"
if [ "$root_usage" -gt 85 ]; then
    class="critical"
elif [ "$root_usage" -gt 70 ]; then
    class="warning"
fi

# Build status
tooltip="Storage: $root_used / $root_total used ($root_usage%)"
if [ -n "$compression_info" ]; then
    tooltip="$tooltip $compression_info"
fi

# Check for recent scrub if btrfs
if [ "$is_btrfs" = "true" ]; then
    scrub_status=$(btrfs scrub status / 2>/dev/null | grep -E "(finished|running)" | tail -1 || echo "")
    if [ -n "$scrub_status" ]; then
        tooltip="$tooltip\nScrub: $scrub_status"
    fi
fi

echo "{\"text\": \"💾 $root_usage%\", \"class\": \"$class\", \"tooltip\": \"$tooltip\"}"