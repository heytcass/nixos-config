#!/usr/bin/env bash
# Cachix Binary Cache Setup Script
# Run this script to set up your personal binary cache

set -euo pipefail

echo "🚀 Setting up Cachix binary cache for faster NixOS builds"
echo ""

# Check if cachix is available
if ! command -v cachix &> /dev/null; then
    echo "📦 Cachix not found in PATH, using nix run..."
    CACHIX_CMD="nix run nixpkgs#cachix --"
else
    CACHIX_CMD="cachix"
fi

echo "📋 Steps to set up your personal binary cache:"
echo ""
echo "1. 🌐 Visit https://app.cachix.org and sign up/log in"
echo "2. 🔑 Get your auth token and run:"
echo "   $CACHIX_CMD authtoken"
echo ""
echo "3. 🏗️  Create a new cache at https://app.cachix.org/cache"
echo "   Suggested name: tom-nixos or heytcass-nixos"
echo ""
echo "4. 📥 Configure the cache locally:"
echo "   $CACHIX_CMD use YOUR-CACHE-NAME"
echo ""
echo "5. ✏️  Update your NixOS configuration:"
echo "   Edit nixos/_mixins/services/base.nix and uncomment the lines:"
echo "   - Add your cache URL to substituters"
echo "   - Add your cache public key to trusted-public-keys"
echo ""
echo "6. 🔄 Rebuild your system:"
echo "   sudo nixos-rebuild switch --flake .#gti"
echo ""
echo "7. 📤 To push builds to your cache:"
echo "   $CACHIX_CMD push YOUR-CACHE-NAME /nix/store/path"
echo "   or"
echo "   $CACHIX_CMD watch-store YOUR-CACHE-NAME"
echo ""
echo "💡 Benefits of personal binary cache:"
echo "   - Much faster rebuilds (download vs compile)"
echo "   - Share builds across multiple machines"
echo "   - Reduce compilation time for custom packages"
echo ""
echo "🎯 Ready to start? Run the commands above!"
