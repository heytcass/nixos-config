#!/usr/bin/env bash
# NixOS Configuration Formatting Script

set -euo pipefail

echo "🔧 Formatting NixOS configuration..."

# Format all Nix files
echo "📝 Formatting Nix files with nixfmt-rfc-style..."
find . -name "*.nix" -not -path "./result*" -exec nix run nixpkgs#nixfmt-rfc-style -- {} \;

# Remove dead code
echo "🧹 Removing dead code with deadnix..."
nix run nixpkgs#deadnix -- --edit

# Check for issues (don't auto-fix)
echo "🔍 Checking for issues with statix..."
if nix run nixpkgs#statix -- check .; then
    echo "✅ No issues found!"
else
    echo "⚠️  Issues found - consider running 'statix fix .' to auto-fix"
fi

echo "✨ Formatting complete!"
