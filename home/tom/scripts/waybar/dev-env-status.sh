#!/bin/bash
# Development environment status for waybar

# Check for active development environments
if [ -n "$IN_NIX_SHELL" ]; then
    if [ -n "$DEV_ENV_TYPE" ]; then
        case "$DEV_ENV_TYPE" in
            "rust")
                echo '{"text": "🦀 rust", "class": "rust", "tooltip": "Development Environment: Rust"}'
                ;;
            "web")
                echo '{"text": "🌐 web", "class": "web", "tooltip": "Development Environment: Web (Node.js/TypeScript)"}'
                ;;
            "python")
                echo '{"text": "🐍 python", "class": "python", "tooltip": "Development Environment: Python"}'
                ;;
            *)
                echo '{"text": "💼 dev", "class": "generic", "tooltip": "Development Environment: Unknown type"}'
                ;;
        esac
    else
        echo '{"text": "❄️ nix", "class": "nix", "tooltip": "Nix Development Shell (generic)"}'
    fi
elif command -v rustc >/dev/null 2>&1 && [ -f "Cargo.toml" ]; then
    echo '{"text": "🦀", "class": "rust-project", "tooltip": "Rust project detected (use dev-env rust)"}'
elif [ -f "package.json" ]; then
    echo '{"text": "🌐", "class": "web-project", "tooltip": "Web project detected (use dev-env web)"}'
elif [ -f "pyproject.toml" ] || [ -f "requirements.txt" ] || [ -f "setup.py" ]; then
    echo '{"text": "🐍", "class": "python-project", "tooltip": "Python project detected (use dev-env python)"}'
else
    echo '{"text": "", "class": "none", "tooltip": "No development environment active"}'
fi