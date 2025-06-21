#!/usr/bin/env bash
# Dell Latitude 7280 (transporter) deployment script using proven disko configuration
# Based on comprehensive disko guide for Dell hardware

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
info() { echo -e "${BLUE}[INFO]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
error() { echo -e "${RED}[ERROR]${NC} $*"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $*"; }

# Check if running as root
if [[ $EUID -ne 0 ]]; then
    error "This script must be run as root or with sudo"
    exit 1
fi

# Dell Latitude 7280 typically uses NVMe
DEVICE="/dev/nvme0n1"

info "Dell Latitude 7280 (transporter) deployment using proven disko configuration"
echo

# Verify device exists
if [[ ! -b "$DEVICE" ]]; then
    error "Device $DEVICE not found!"
    info "Available storage devices:"
    lsblk
    echo
    warn "Dell Latitude 7280 typically uses /dev/nvme0n1"
    warn "If your device is different, edit this script to update DEVICE variable"
    exit 1
fi

# Show current device info
info "Target device information:"
lsblk "$DEVICE"
echo

# Critical warning
echo "🚨 CRITICAL WARNING 🚨"
warn "This will COMPLETELY DESTROY all data on $DEVICE"
warn "Make sure you have:"
warn "  ✓ Backed up all important data"
warn "  ✓ Verified this is the correct device"
warn "  ✓ Confirmed Dell Latitude 7280 BIOS settings:"
warn "    - Secure Boot: DISABLED"
warn "    - SATA Operation: AHCI (not RAID)"
warn "    - UEFI Boot Mode: ENABLED"
warn "    - Fast Boot: DISABLED"
echo
read -p "Type 'DELETE_ALL_DATA' to confirm: " confirm

if [[ "$confirm" != "DELETE_ALL_DATA" ]]; then
    info "Deployment cancelled - data preserved"
    exit 0
fi

echo
info "Starting deployment..."

# Phase 1: Validate configuration
info "Phase 1: Validating disko configuration..."
if ! nix --experimental-features "nix-command flakes" eval .#nixosConfigurations.transporter.config.disko.devices >/dev/null 2>&1; then
    error "Disko configuration validation failed!"
    error "Check your flake.nix and hosts/transporter/disko-config.nix"
    exit 1
fi
success "Configuration validation passed"

# Phase 2: Use disko-install (recommended approach)
info "Phase 2: Attempting streamlined disko-install..."
if nix run 'github:nix-community/disko/latest#disko-install' -- \
    --flake ".#transporter" \
    --disk main "$DEVICE"; then
    
    success "disko-install completed successfully!"
    
else
    warn "disko-install failed, falling back to manual step-by-step process..."
    
    # Manual fallback process
    info "Step 1: Partition and format disk..."
    nix --experimental-features "nix-command flakes" run \
        github:nix-community/disko/latest -- \
        --mode destroy,format,mount \
        ./hosts/transporter/disko-config.nix
    
    info "Step 2: Generate hardware configuration..."
    nixos-generate-config --no-filesystems --root /mnt
    
    info "Step 3: Install NixOS..."
    nixos-install --root /mnt --flake '.#transporter'
fi

# Phase 3: Post-installation validation
info "Phase 3: Validating installation..."

if [[ -d /mnt/etc/nixos ]]; then
    success "NixOS installation completed successfully!"
    echo
    info "Next steps:"
    info "1. Set root password:"
    info "   nixos-enter --root /mnt -c 'passwd'"
    echo
    info "2. Set user password:"
    info "   nixos-enter --root /mnt -c 'passwd tom'"
    echo
    info "3. Verify system after reboot:"
    info "   sudo btrfs filesystem show"
    info "   sudo btrfs subvolume list /"
    info "   mount | grep btrfs"
    echo
    info "4. Create initial snapshots (after first boot):"
    info "   sudo btrfs subvolume snapshot -r / /.snapshots/initial"
    echo
    success "🎉 Dell Latitude 7280 deployment complete!"
    warn "⚠️  Reboot to complete installation: reboot"
    
else
    error "Installation appears to have failed - /mnt/etc/nixos not found"
    exit 1
fi