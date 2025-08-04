#!/usr/bin/env bash
# YubiKey PIV SSH Key Setup Helper
# Interactive script to generate SSH key in PIV authentication slot

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."
    
    # Check if YubiKey is connected
    if ! ykman list >/dev/null 2>&1; then
        log_error "No YubiKey detected. Please connect your YubiKey and try again."
        exit 1
    fi
    
    local yubikey_info
    yubikey_info=$(ykman list)
    log_success "YubiKey detected: $yubikey_info"
    
    # Check PIV application
    if ! ykman piv info >/dev/null 2>&1; then
        log_error "Cannot access PIV application. Please ensure YubiKey is properly connected."
        exit 1
    fi
    
    log_success "PIV application accessible"
}

# Show current PIV status
show_piv_status() {
    log_info "Current PIV application status:"
    ykman piv info
    
    echo ""
    log_info "Checking PIV authentication slot (9a):"
    if ykman piv certificates export 9a - >/dev/null 2>&1; then
        log_warning "Authentication slot 9a already contains a certificate"
        log_warning "This script will replace any existing key in slot 9a"
        
        echo ""
        read -p "Do you want to continue and replace the existing key? (y/N): " -r
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            log_info "Aborted by user"
            exit 0
        fi
    else
        log_info "Authentication slot 9a is empty - ready for key generation"
    fi
}

# Generate PIV SSH key
generate_piv_key() {
    log_info "Generating ECCP256 key in PIV authentication slot (9a)..."
    log_warning "You will be prompted for the PIV PIN (default is 123456)"
    log_warning "You will need to touch your YubiKey when it blinks"
    
    echo ""
    if ykman piv keys generate --algorithm=ECCP256 --pin-policy=ONCE --touch-policy=CACHED 9a /tmp/yubikey_public.pem; then
        log_success "PIV key generated successfully"
    else
        log_error "PIV key generation failed"
        exit 1
    fi
    
    log_info "Creating self-signed certificate for SSH usage..."
    log_warning "You will be prompted for the PIV PIN again"
    log_warning "You will need to touch your YubiKey when it blinks"
    
    echo ""
    if ykman piv certificates generate --subject "CN=YubiKey SSH $(date +%Y%m%d)" 9a /tmp/yubikey_public.pem; then
        log_success "Certificate created successfully"
    else
        log_error "Certificate generation failed"
        exit 1
    fi
    
    # Clean up temporary file
    rm -f /tmp/yubikey_public.pem
}

# Test SSH functionality
test_ssh_functionality() {
    log_info "Testing SSH functionality..."
    
    # Restart yubikey-agent to detect new key
    if systemctl --user restart yubikey-agent; then
        log_success "YubiKey agent restarted"
    else
        log_warning "Failed to restart yubikey-agent"
    fi
    
    # Give it a moment to detect the key
    sleep 2
    
    # Test SSH key listing
    log_info "Checking if SSH key is available through YubiKey agent..."
    local ssh_key_output
    if ssh_key_output=$(SSH_AUTH_SOCK=/run/user/1000/yubikey-agent/yubikey-agent.sock ssh-add -L 2>&1); then
        log_success "YubiKey SSH key detected:"
        echo "$ssh_key_output"
        
        # Test GitHub authentication if configured
        echo ""
        log_info "Testing SSH authentication with GitHub..."
        if ssh -T git@github.com 2>&1 | grep -q "successfully authenticated"; then
            log_success "GitHub SSH authentication working!"
        else
            log_warning "GitHub SSH authentication test inconclusive"
            log_info "If you use GitHub, make sure to add the SSH key above to your GitHub account"
        fi
    else
        log_warning "YubiKey SSH key not detected by agent"
        log_info "Agent output: $ssh_key_output"
    fi
}

# Show final instructions
show_final_instructions() {
    echo ""
    log_success "YubiKey PIV SSH setup completed!"
    echo ""
    log_info "What was configured:"
    log_info "• ECCP256 key generated in PIV authentication slot 9a"
    log_info "• Self-signed certificate created for SSH usage"
    log_info "• YubiKey agent restarted to detect new key"
    echo ""
    log_info "Next steps:"
    log_info "• Add the SSH public key (shown above) to your GitHub/GitLab/etc. accounts"
    log_info "• SSH will now use your YubiKey for authentication (requires touch)"
    log_info "• The YubiKey must be connected for SSH operations"
    echo ""
    log_info "To see your SSH public key again:"
    log_info "SSH_AUTH_SOCK=/run/user/1000/yubikey-agent/yubikey-agent.sock ssh-add -L"
    echo ""
    log_info "Security notes:"
    log_info "• Touch policy: Cached - one touch per session"
    log_info "• PIN policy: Once - PIN required once per session"
    log_info "• Keep your YubiKey PIN secure (default is 123456 - consider changing it)"
}

# Main execution
main() {
    log_info "YubiKey PIV SSH Key Setup"
    log_info "This script will generate an SSH key in your YubiKey's PIV authentication slot"
    echo ""
    
    check_prerequisites
    show_piv_status
    generate_piv_key
    test_ssh_functionality
    show_final_instructions
}

main "$@"