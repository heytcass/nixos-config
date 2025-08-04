#!/usr/bin/env bash
# Post-Installation Setup Script for NixOS Professional Workstation
# This script automates the manual steps required after a fresh NixOS installation
# Based on PRD.md Phase 1 & 2 post-deployment requirements

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check if running as user (not root)
if [ "$EUID" -eq 0 ]; then
    log_error "Do not run this script as root. Run as regular user."
    exit 1
fi

log_info "Starting post-installation setup for NixOS Professional Workstation"
log_info "This script automates the manual steps from PRD.md"

# 1. YubiKey Integration
setup_yubikey() {
    log_info "Setting up YubiKey integration..."
    
    # Check if YubiKey is connected
    if ! ykman list >/dev/null 2>&1; then
        log_warning "No YubiKey detected. Please connect your YubiKey and press Enter to continue."
        read -r
    fi
    
    # Create Yubico config directory
    mkdir -p ~/.config/Yubico
    
    # Register for FIDO2/U2F (requires user interaction)
    log_info "Registering YubiKey for FIDO2/U2F authentication..."
    log_warning "You will need to touch your YubiKey when it blinks."
    if pamu2fcfg > ~/.config/Yubico/u2f_keys 2>/dev/null; then
        log_success "YubiKey FIDO2/U2F registration completed"
    else
        log_error "FIDO2/U2F registration failed - you may need to touch the YubiKey"
        return 1
    fi
    
    # Check PIV authentication slot
    log_info "Checking PIV authentication slot (9a)..."
    if ! ykman piv certificates export 9a - >/dev/null 2>&1; then
        log_warning "PIV authentication slot (9a) is empty. SSH with YubiKey requires a key in this slot."
        log_warning "To generate a new key, run: ykman piv keys generate --algorithm ECCP256 --pin-policy ONCE --touch-policy CACHED 9a /tmp/pubkey.pem"
        log_warning "Then create certificate: ykman piv certificates generate --subject 'CN=YubiKey SSH' 9a /tmp/pubkey.pem"
        log_warning "This requires interactive PIN entry and cannot be automated."
    else
        log_success "PIV authentication slot has a certificate"
    fi
    
    # Restart yubikey-agent
    systemctl --user restart yubikey-agent
    log_success "YubiKey agent restarted"
}

# 2. Secrets Management
setup_secrets() {
    log_info "Setting up secrets management..."
    
    # Check if age key exists
    if [ ! -f ~/.config/sops/age/keys.txt ]; then
        log_error "Age key not found at ~/.config/sops/age/keys.txt"
        log_error "This should have been created during initial setup"
        return 1
    fi
    
    # Verify age key matches what's in sops config
    USER_AGE_KEY=$(grep "^# public key:" ~/.config/sops/age/keys.txt | cut -d' ' -f4)
    log_info "User age key: $USER_AGE_KEY"
    
    # Fix system age key if needed
    log_info "Checking system age key..."
    SYSTEM_HOST_KEY=$(sudo ssh-to-age < /etc/ssh/ssh_host_ed25519_key.pub)
    log_info "System host key (age format): $SYSTEM_HOST_KEY"
    
    # Check if system age key matches
    if sudo test -f /var/lib/sops-nix/key.txt; then
        CURRENT_SYSTEM_KEY=$(sudo grep "^# public key:" /var/lib/sops-nix/key.txt | cut -d' ' -f4 || echo "none")
        if [ "$CURRENT_SYSTEM_KEY" != "$SYSTEM_HOST_KEY" ]; then
            log_warning "System age key mismatch detected. Fixing..."
            sudo ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key | sudo tee /var/lib/sops-nix/key.txt > /dev/null
            log_success "System age key updated to match SSH host key"
        else
            log_success "System age key is correct"
        fi
    else
        log_warning "System age key file not found. Creating from SSH host key..."
        sudo mkdir -p /var/lib/sops-nix
        sudo ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key | sudo tee /var/lib/sops-nix/key.txt > /dev/null
        sudo chmod 600 /var/lib/sops-nix/key.txt
        log_success "System age key created"
    fi
}

# 3. Container Platform
setup_containers() {
    log_info "Setting up container platform..."
    
    # Enable user lingering
    if ! loginctl show-user "$(whoami)" | grep -q "Linger=yes"; then
        log_info "Enabling user lingering for rootless containers..."
        sudo loginctl enable-linger "$(whoami)"
        log_success "User lingering enabled"
    else
        log_success "User lingering already enabled"
    fi
    
    # Verify rootless Podman
    if command -v podman >/dev/null 2>&1; then
        PODMAN_ROOT=$(podman system info --format json | jq -r '.host.runRoot' 2>/dev/null || echo "")
        if [[ "$PODMAN_ROOT" == *"/run/user/"* ]]; then
            log_success "Rootless Podman configuration verified"
        else
            log_warning "Podman may not be configured for rootless operation"
        fi
    fi
}

# 4. Audio/Video Setup Verification
verify_av_setup() {
    log_info "Verifying audio/video setup..."
    
    # Check v4l2loopback module
    if lsmod | grep -q v4l2loopback; then
        log_success "v4l2loopback module loaded"
    else
        log_error "v4l2loopback module not loaded - virtual camera won't work"
        return 1
    fi
    
    # Check if virtual camera device exists
    if [ -c /dev/video0 ]; then
        log_success "Virtual camera device /dev/video0 exists"
    else
        log_warning "Virtual camera device /dev/video0 not found"
    fi
    
    # List available cameras
    log_info "Available cameras:"
    v4l2-ctl --list-devices 2>/dev/null || log_warning "v4l2-ctl not available"
    
    # Check EasyEffects
    if command -v easyeffects >/dev/null 2>&1; then
        log_success "EasyEffects available"
        log_info "Remember to create 'Professional Calls Input' preset with effects chain:"
        log_info "  Gate -> Compressor -> Filter -> Limiter (on Input tab)"
    else
        log_warning "EasyEffects not found"
    fi
    
    # Check OBS
    if command -v obs >/dev/null 2>&1; then
        log_success "OBS Studio available"
        log_info "Remember to configure Video Call Scene with camera source"
    else
        log_warning "OBS Studio not found"
    fi
}

# 5. System rebuild to activate any configuration changes
rebuild_system() {
    log_info "Rebuilding system to activate any configuration changes..."
    if command -v rebuild >/dev/null 2>&1; then
        log_warning "About to rebuild system. This requires sudo privileges."
        log_warning "Press Enter to continue or Ctrl+C to skip..."
        read -r
        sudo nixos-rebuild switch --flake ~/.nixos#gti
        log_success "System rebuild completed"
    else
        log_warning "rebuild command not found. Run manually: sudo nixos-rebuild switch --flake ~/.nixos#gti"
    fi
}

# Main execution
main() {
    log_info "=== YubiKey Integration ==="
    setup_yubikey || log_error "YubiKey setup encountered issues"
    
    log_info "=== Secrets Management ==="
    setup_secrets || log_error "Secrets setup encountered issues"
    
    log_info "=== Container Platform ==="
    setup_containers || log_error "Container setup encountered issues"
    
    log_info "=== Audio/Video Verification ==="
    verify_av_setup || log_error "A/V setup has issues"
    
    log_info "=== System Rebuild ==="
    rebuild_system || log_error "System rebuild encountered issues"
    
    log_success "Post-installation setup completed!"
    log_info "Next steps:"
    log_info "1. If YubiKey PIV slot 9a was empty, generate SSH key manually"
    log_info "2. Configure EasyEffects 'Professional Calls Input' preset"
    log_info "3. Set up OBS Video Call Scene with your camera"
    log_info "4. Test video calls with 'OBS Virtual Camera' and 'EasyEffects Source'"
}

# Run main function
main "$@"