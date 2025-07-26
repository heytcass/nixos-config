#!/bin/bash
# Git project launcher for waybar

# Common development directories
SEARCH_DIRS=(
    "$HOME/git"
    "$HOME/projects"
    "$HOME/Development"
    "$HOME/.nixos"
    "$HOME/work"
)

# Find git repositories
PROJECTS=()
for dir in "${SEARCH_DIRS[@]}"; do
    if [ -d "$dir" ]; then
        while IFS= read -r -d '' repo; do
            repo_name=$(basename "$repo")
            repo_path=$(dirname "$repo")
            PROJECTS+=("📁 $repo_name|$repo_path")
        done < <(find "$dir" -maxdepth 2 -name ".git" -type d -print0 2>/dev/null)
    fi
done

# Add current directory if it's a git repo
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    current_dir=$(pwd)
    current_name=$(basename "$current_dir")
    PROJECTS=("📍 $current_name (current)|$current_dir" "${PROJECTS[@]}")
fi

# Create wofi menu
if [ ${#PROJECTS[@]} -eq 0 ]; then
    notify-send "Git Projects" "No git repositories found"
    exit 0
fi

# Format for wofi (remove paths from display)
DISPLAY_PROJECTS=$(printf '%s\n' "${PROJECTS[@]}" | cut -d'|' -f1)

CHOICE=$(echo "$DISPLAY_PROJECTS" | wofi --dmenu --prompt="Git Projects" --width=400 --height=300)

if [ -n "$CHOICE" ]; then
    # Find the full path for the selected project
    for project in "${PROJECTS[@]}"; do
        if [[ "$project" == "$CHOICE|"* ]]; then
            project_path=$(echo "$project" | cut -d'|' -f2)
            cd "$project_path" && ghostty
            break
        fi
    done
fi
