#!/usr/bin/env bash
# Git commit with automatic formatting
# Usage: ./scripts/git-commit-clean.sh "commit message"

set -euo pipefail

if [ $# -eq 0 ]; then
    echo "Usage: $0 \"commit message\""
    exit 1
fi

COMMIT_MSG="$1"

echo "🔧 Formatting Nix files..."
nix run nixpkgs#nixfmt-rfc-style -- **/*.nix

echo "🧹 Removing dead code..."
nix run nixpkgs#deadnix -- --edit

echo "📦 Staging all changes..."
git add .

echo "💾 Committing with pre-commit hooks..."
git commit -m "$COMMIT_MSG"

echo "✅ Commit completed successfully!"
