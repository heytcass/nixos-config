# NixOS Professional Workstation Setup Guide

This guide provides automated scripts and instructions for setting up the complete professional workstation configuration from scratch.

## Quick Start (Fresh Install)

After deploying the NixOS configuration on a new machine:

```bash
# Navigate to the configuration directory
cd ~/.nixos

# Run the main post-installation setup script
./scripts/post-install-setup.sh

# Import audio/video configurations
./scripts/import-av-configs.sh

# Set up YubiKey PIV SSH (interactive)
./scripts/yubikey-piv-setup.sh
```

## What Each Script Does

### 1. `scripts/post-install-setup.sh`
**Automates the critical post-deployment steps:**
- ✅ YubiKey FIDO2/U2F registration
- ✅ Age key verification and system key fixing
- ✅ Container platform verification (user lingering now declarative)
- ✅ Audio/video module verification
- ✅ System rebuild with any configuration changes

**Limitations:**
- YubiKey PIV SSH key generation requires interactive setup (separate script)
- EasyEffects and OBS configuration requires separate import

### 2. `scripts/import-av-configs.sh`
**Automates audio/video configuration:**
- ✅ Imports EasyEffects "Professional Calls Input" preset with full effects chain
- ✅ Creates basic OBS "Professional Calls" scene collection
- ✅ Sets up EasyEffects auto-start on login
- ✅ Configures default audio processing preset

**What this replaces:**
- Manual EasyEffects effects chain creation (Gate → Compressor → Filter → Limiter)
- Manual OBS scene setup with camera source
- Manual preset configuration and auto-start setup

### 3. `scripts/yubikey-piv-setup.sh`
**Interactive YubiKey PIV SSH setup:**
- ✅ Checks YubiKey connectivity and PIV application
- ✅ Generates ECCP256 key in authentication slot 9a
- ✅ Creates self-signed certificate for SSH usage
- ✅ Tests SSH functionality and GitHub authentication
- ✅ Provides clear next steps and public key display

**What this replaces:**
- Manual `ykman piv keys generate` commands
- Manual certificate generation
- Manual agent restart and testing

## Declarative vs Script-Based Components

### ✅ Fully Declarative (Survives Fresh Install)
- **NixOS System Configuration**: All packages, services, kernel modules
- **Home Manager**: SSH config, shell setup, development tools
- **YubiKey Services**: yubikey-agent, pcscd automatically configured
- **Audio/Video Stack**: OBS, EasyEffects, PipeWire, v4l2loopback modules
- **Container Platform**: Rootless Podman configuration
- **User Lingering**: Now declared in systemd.nix (no manual setup needed)

### ⚠️ Semi-Automated (Scripts Required)
- **YubiKey PIV Keys**: Hardware interaction requires interactive setup
- **Secrets Age Keys**: System key derivation and verification
- **EasyEffects Presets**: JSON configuration import
- **OBS Scene Collections**: Basic scene setup automation

### 🔄 One-Time Manual (Cannot Be Automated)
- **YubiKey PIN Changes**: Security-sensitive, user decision
- **GitHub SSH Key Addition**: External service, requires user action
- **Call Application Settings**: Per-application audio/video source selection

## Fresh Install Checklist

### Initial NixOS Deployment
```bash
# 1. Deploy base configuration
sudo nixos-rebuild switch --flake ~/.nixos#gti

# 2. Verify system health
systemctl status
systemctl --user status

# 3. Test basic functionality
firefox # or preferred browser
code # VS Code should launch
```

### Post-Deployment Automation
```bash
# 4. Run automated setup
./scripts/post-install-setup.sh

# 5. Import A/V configurations  
./scripts/import-av-configs.sh

# 6. Configure YubiKey PIV (interactive)
./scripts/yubikey-piv-setup.sh
```

### Manual Configuration Steps
```bash
# 7. Add SSH key to GitHub/GitLab
SSH_AUTH_SOCK=/run/user/1000/yubikey-agent/yubikey-agent.sock ssh-add -L
# Copy the displayed key to your Git service

# 8. Test complete setup
obs # Launch OBS and start virtual camera
easyeffects # Verify professional preset is loaded
# Test video call with "OBS Virtual Camera" and "EasyEffects Source"
```

## Configuration Files Reference

### Scripts Location: `~/.nixos/scripts/`
- `post-install-setup.sh` - Main automation script
- `import-av-configs.sh` - Audio/video configuration import
- `yubikey-piv-setup.sh` - Interactive YubiKey PIV setup

### Configs Location: `~/.nixos/configs/`
- `easyeffects-professional-calls.json` - Complete EasyEffects preset
- (Future: OBS scene collections, camera presets)

### Generated Configurations
- `~/.config/easyeffects/input/Professional Calls Input.json` - Imported preset
- `~/.config/obs-studio/basic/scenes/Professional Calls.json` - Basic scene
- `~/.config/Yubico/u2f_keys` - FIDO2/U2F registration
- `~/.config/autostart/easyeffects.desktop` - Auto-start configuration

## Troubleshooting

### YubiKey Issues
```bash
# Check connectivity
ykman list

# Restart services
sudo systemctl restart pcscd
systemctl --user restart yubikey-agent

# Test PIV functionality
ykman piv info
```

### Audio/Video Issues
```bash
# Check virtual camera
ls -la /dev/video*

# Check v4l2loopback module
lsmod | grep v4l2loopback

# Test EasyEffects
easyeffects --quit && easyeffects &

# Check PipeWire
helvum  # Visual audio routing
```

### Secrets Issues
```bash
# Test decryption
sops -d ~/.nixos/secrets/secrets.yaml | head -5

# Check system key
sudo cat /var/lib/sops-nix/key.txt | grep "^# public key:"

# Verify mounted secrets
sudo ls -la /run/secrets/
```

## Architecture Notes

### Why Scripts Instead of Full Declarative?
1. **Hardware Interaction**: YubiKey PIV requires user PIN entry and touch
2. **External Dependencies**: GitHub SSH key addition requires manual action
3. **Security Decisions**: PIN changes and key generation should be user-controlled
4. **Application Configs**: Some apps store config in formats that don't map well to Nix

### Automation Strategy
- **Maximum Declarative**: Everything that can be declared in Nix is declared
- **Scripted Setup**: One-time configuration that requires logic or interaction
- **Manual Steps**: Only security-sensitive or external service operations

This approach provides the best balance of automation, security, and maintainability for a professional development environment.

## Future Improvements

Potential areas for enhanced automation:
- [ ] OBS scene templates with multiple camera configurations
- [ ] Camera settings presets for different lighting conditions  
- [ ] Application-specific audio/video settings automation
- [ ] Backup/restore scripts for user configurations
- [ ] Health check scripts for complete system verification