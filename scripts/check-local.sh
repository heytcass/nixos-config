#!/usr/bin/env bash
# Local validation script - run before pushing to avoid CI failures

set -e

echo "🔍 Running local NixOS configuration checks..."

# Color output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check flake
echo -e "\n${YELLOW}Checking flake structure...${NC}"
if nix flake check --no-build 2>/dev/null; then
    echo -e "${GREEN}✓ Flake structure is valid${NC}"
else
    echo -e "${RED}✗ Flake check failed${NC}"
    exit 1
fi

# Evaluate configs
echo -e "\n${YELLOW}Evaluating configurations...${NC}"
for host in gti transporter; do
    echo -n "  Checking $host... "
    if nix eval .#nixosConfigurations.$host.config.system.build.toplevel.outPath &>/dev/null; then
        echo -e "${GREEN}✓${NC}"
    else
        echo -e "${RED}✗${NC}"
        echo "    Run: nix eval .#nixosConfigurations.$host.config.system.build.toplevel.outPath"
        exit 1
    fi
done

# Check formatting
echo -e "\n${YELLOW}Checking code formatting...${NC}"
if nix run nixpkgs#nixpkgs-fmt -- --check . &>/dev/null; then
    echo -e "${GREEN}✓ Code is properly formatted${NC}"
else
    echo -e "${YELLOW}⚠ Some files need formatting${NC}"
    echo "  Run: nix run nixpkgs#nixpkgs-fmt ."
fi

# Check for anti-patterns
echo -e "\n${YELLOW}Checking for anti-patterns...${NC}"
if nix run nixpkgs#statix -- check . 2>&1 | grep -q "Found 0 issues"; then
    echo -e "${GREEN}✓ No anti-patterns detected${NC}"
else
    echo -e "${YELLOW}⚠ Statix found some suggestions${NC}"
    echo "  Run: nix run nixpkgs#statix -- check ."
fi

# Check git status
echo -e "\n${YELLOW}Checking git status...${NC}"
if [ -n "$(git status --porcelain)" ]; then
    echo -e "${YELLOW}⚠ You have uncommitted changes:${NC}"
    git status --short
else
    echo -e "${GREEN}✓ Working directory clean${NC}"
fi

echo -e "\n${GREEN}✅ All checks passed! Safe to push.${NC}"