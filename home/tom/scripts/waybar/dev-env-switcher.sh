#!/bin/bash
# Development environment switcher for waybar

# Create wofi menu for development environment switching
ENV_CHOICE=$(echo -e "🦀 rust\n🌐 web\n🐍 python\n💼 system\n❄️ nix develop" | wofi --dmenu --prompt="Development Environment" --width=300 --height=200)

case "$ENV_CHOICE" in
    "🦀 rust")
        ghostty -e dev-env rust
        ;;
    "🌐 web")
        ghostty -e dev-env web
        ;;
    "🐍 python")
        ghostty -e dev-env python
        ;;
    "💼 system")
        ghostty
        ;;
    "❄️ nix develop")
        if [ -f "flake.nix" ]; then
            ghostty -e nix develop
        else
            notify-send "Nix Develop" "No flake.nix found in current directory"
        fi
        ;;
esac
