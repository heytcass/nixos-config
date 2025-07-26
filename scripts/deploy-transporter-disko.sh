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

# Get device from argument or default to /dev/sda
DEVICE="${1:-/dev/sda}"

# Show usage if help requested
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    echo "Usage: $0 [DEVICE]"
    echo "  DEVICE: Target storage device (default: /dev/sda)"
    echo ""
    echo "Examples:"
    echo "  $0                    # Use default /dev/sda"
    echo "  $0 /dev/nvme0n1       # Use NVMe device"
    echo "  $0 /dev/sdb           # Use second SATA device"
    echo ""
    echo "Available storage devices:"
    lsblk -d -o NAME,SIZE,MODEL
    exit 0
fi

info "Dell Latitude 7280 (transporter) deployment using proven disko configuration"
info "Target device: $DEVICE"
echo

# Verify device exists
if [[ ! -b "$DEVICE" ]]; then
    error "Device $DEVICE not found!"
    echo
    info "Available storage devices:"
    lsblk -d -o NAME,SIZE,MODEL,TYPE
    echo
    warn "Run '$0 --help' to see usage examples"
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

# Phase 1: Update disko config and validate
info "Phase 1: Updating disko configuration for target device..."
# Temporarily update the device in disko config
sed -i.bak "s|device = \"/dev/[^\"]*\"|device = \"$DEVICE\"|g" hosts/transporter/disko-config.nix

info "Validating disko configuration..."
if ! nix --extra-experimental-features "nix-command flakes" eval .#nixosConfigurations.transporter.config.disko.devices >/dev/null 2>&1; then
    error "Disko configuration validation failed!"
    error "Check your flake.nix and hosts/transporter/disko-config.nix"
    # Restore backup
    mv hosts/transporter/disko-config.nix.bak hosts/transporter/disko-config.nix 2>/dev/null || true
    exit 1
fi
success "Configuration validation passed"

info "Checking system readiness for disko-install..."
# Check network connectivity to binary caches
if ! curl -s --connect-timeout 5 https://cache.nixos.org > /dev/null; then
    warn "Cannot reach cache.nixos.org - this may cause build failures"
    warn "Ensure network connectivity for best results"
fi

# Check available memory (disko-install needs sufficient RAM)
available_mem=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
if [ "$available_mem" -lt 1048576 ]; then  # Less than 1GB
    warn "Low available memory ($((available_mem/1024))MB) - builds may fail"
    warn "Consider using manual fallback if disko-install fails"
fi

# Pre-download disko to avoid network issues during critical phase
info "Pre-downloading disko components..."
nix --extra-experimental-features "nix-command flakes" \
    --option connect-timeout 10 \
    build 'github:nix-community/disko/latest#disko-install' >/dev/null 2>&1 || {
    warn "Could not pre-download disko - may fallback to manual process"
}

# Phase 2: Use disko-install (recommended approach)
info "Phase 2: Attempting streamlined disko-install..."
# Add extra substituters and build settings for reliability
if nix --extra-experimental-features "nix-command flakes" \
    --option substituters "https://cache.nixos.org/ https://nix-community.cachix.org" \
    --option trusted-public-keys "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs=" \
    --option max-jobs "auto" \
    --option cores "0" \
    --option connect-timeout 10 \
    --option stalled-download-timeout 30 \
    run 'github:nix-community/disko/latest#disko-install' -- \
    --flake ".#transporter" \
    --disk main "$DEVICE"; then

    success "disko-install completed successfully!"

else
    warn "disko-install failed, falling back to manual step-by-step process..."

    # Manual fallback process
    info "Step 1: Partition and format disk..."
    nix --extra-experimental-features "nix-command flakes" run \
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
    # Restore backup before exiting
    mv hosts/transporter/disko-config.nix.bak hosts/transporter/disko-config.nix 2>/dev/null || true
    exit 1
fi

# Restore original disko config
mv hosts/transporter/disko-config.nix.bak hosts/transporter/disko-config.nix 2>/dev/null || true
