#!/bin/bash
# Enhanced git status for waybar

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    branch=$(git branch --show-current 2>/dev/null || echo "unknown")

    # Count changes
    changes=$(git status --porcelain 2>/dev/null | wc -l)

    # Check for unpushed commits
    unpushed=$(git rev-list --count "@{u}..HEAD" 2>/dev/null || echo "0")

    # Check for stashes
    stashes=$(git stash list 2>/dev/null | wc -l)

    # Build tooltip
    tooltip="Git: $branch"
    if [ "$changes" -gt 0 ]; then
        tooltip="$tooltip ($changes changes)"
    else
        tooltip="$tooltip (clean)"
    fi

    if [ "$unpushed" -gt 0 ]; then
        tooltip="$tooltip, $unpushed unpushed"
    fi

    if [ "$stashes" -gt 0 ]; then
        tooltip="$tooltip, $stashes stashed"
    fi

    # Determine status class and icon
    if [ "$changes" -gt 0 ]; then
        echo "{\"text\": \" $branch\", \"class\": \"git-dirty\", \"tooltip\": \"$tooltip\"}"
    else
        echo "{\"text\": \" $branch\", \"class\": \"git-clean\", \"tooltip\": \"$tooltip\"}"
    fi
else
    echo "{\"text\": \"\", \"class\": \"git-none\", \"tooltip\": \"Not in git repository\"}"
fi
