# Multi-Platform NixOS Configuration Guide

This guide documents the platform abstraction system that allows deploying the same professional workstation setup across different hardware platforms.

## Supported Platforms

### Dell XPS 13 9370 (`gti`)
- **Status**: Production system (DO NOT MODIFY)
- **Filesystem**: ext4
- **Hardware Profile**: `hardware/dell-xps-13-9370.nix`
- **Configuration**: `configuration.nix`
- **Features**: Secure boot, YubiKey integration, professional A/V setup

### Dell Latitude 7280 (`transporter`)
- **Status**: Test/development system
- **Filesystem**: btrfs with subvolumes and compression
- **Hardware Profile**: `hardware/dell-latitude-7280.nix`
- **Configuration**: `transporter-configuration.nix`
- **Features**: Same as XPS but with btrfs optimizations

## Architecture Overview

### Platform Abstraction
The system uses a modular approach with hardware-specific profiles:

```
hardware/
├── dell-xps-13-9370.nix      # XPS-specific settings
├── dell-latitude-7280.nix    # Latitude-specific settings
└── transporter-hardware-configuration.nix  # Latitude hardware config
```

### Shared Configuration
All platforms share the same core modules:
- `modules/options.nix` - Typed configuration options
- `modules/boot.nix` - Boot and kernel settings
- `modules/hardware.nix` - Generic hardware optimizations
- `modules/desktop.nix` - GNOME desktop environment
- `modules/networking.nix` - Network configuration
- `modules/security.nix` - Security policies
- `modules/performance.nix` - Performance tuning
- `modules/tools.nix` - Development tools
- `modules/secrets.nix` - Secrets management

### Platform-Specific Features

#### Btrfs Configuration (Latitude 7280)
- **Subvolumes**:
  - `/` (rootfs) - System files with snapshots
  - `/home` - User data with compression
  - `/nix` - Nix store with compression + noatime
  - `/persist` - Critical system state
  - `/snapshots` - Organized snapshot storage
- **Features**:
  - Transparent zstd compression
  - Automatic monthly scrubbing
  - Copy-on-write for efficient snapshots

## Direct Installation

### Simple Installation
```bash
# Boot target machine from NixOS installer ISO
# Enable SSH: sudo systemctl start sshd
# Set password: sudo passwd nixos

# From your development machine - single command:
nix run .#install-transporter <target-ip>

# Or directly with nixos-anywhere:
nix run github:nix-community/nixos-anywhere -- \
  --flake .#transporter \
  --target-host nixos@<target-ip>
```

### Prerequisites
1. Target machine booted from NixOS installer ISO
2. SSH access enabled on target
3. Network connectivity from target machine
4. Sufficient disk space (minimum 32GB recommended)

## Post-Installation Setup

The system now includes **automated post-installation setup** that runs on first boot:

### Automatic Setup (No Manual Steps Required)
After installation and reboot, the system automatically:
- ✅ **Validates age key configuration** for secrets management
- ✅ **Prepares YubiKey FIDO2/U2F directories**
- ✅ **Verifies all essential services** are running
- ✅ **Shows setup completion notification** on first login

### Manual Steps (Only These Remain)
```bash
# SSH to the new system
ssh tom@<target-ip>

# 1. Generate YubiKey PIV SSH key (interactive - requires PIN/touch)
nix run .#setup-yubikey-piv

# 2. Add SSH public key to GitHub/GitLab (external service)
# Key is displayed by the command above

# 3. Test complete setup
obs                    # Launch OBS Studio
easyeffects           # Launch EasyEffects
```

### What's Now Fully Automated
- ❌ ~~Age key generation and validation~~ → **Automatic**
- ❌ ~~YubiKey FIDO2/U2F registration~~ → **Automatic** 
- ❌ ~~Container platform setup~~ → **Automatic**
- ❌ ~~EasyEffects configuration~~ → **Declarative via Home Manager**
- ❌ ~~OBS configuration~~ → **Declarative via Home Manager**
- ❌ ~~Service verification~~ → **Automatic**

## Development Workflow

### Safe Development Practices
1. **Always work on `platform-expansion` branch**
2. **Never modify XPS 13 9370 configuration directly**
3. **Test all changes on Latitude 7280 first**
4. **Use separate flake outputs for each platform**

### Adding New Platforms
1. Create hardware profile in `hardware/new-platform.nix`
2. Add nixos-hardware module if available
3. Create platform-specific configuration if needed
4. Add new flake output in `flake.nix`
5. Test thoroughly before production use

### Configuration Management
- **Hardware-specific settings**: In hardware profiles
- **Shared settings**: In core modules
- **Platform selection**: Via flake outputs
- **Secrets**: Managed by sops-nix across all platforms

## File System Differences

### XPS 13 9370 (ext4)
```
/dev/nvme0n1p1  /boot  (vfat)
/dev/nvme0n1p2  swap
/dev/nvme0n1p3  /      (ext4)
```

### Latitude 7280 (btrfs)
```
/dev/sda1       /boot  (vfat)
/dev/sda2       swap
/dev/sda3       /      (btrfs)
  ├── rootfs    /      (subvolume)
  ├── home      /home  (subvolume)
  ├── nix       /nix   (subvolume)
  ├── persist   /persist (subvolume)
  └── snapshots (unmounted)
```

## Troubleshooting

### Installation Issues
- **SSH connectivity**: Ensure SSH is started and password is set
- **Network issues**: Check internet connectivity from installer
- **Hardware compatibility**: Verify nixos-hardware support
- **Disk space**: Ensure sufficient free space on target disk

### Platform-Specific Issues
- **Btrfs**: Check subvolume mounting with `btrfs subvolume list /`
- **Hardware**: Verify correct nixos-hardware module is loaded
- **Secrets**: Ensure age keys are properly generated

### Recovery Procedures
- **Rollback**: Use git to revert to previous working configuration
- **Backup**: XPS configuration backed up before any changes
- **Snapshots**: Btrfs snapshots available for Latitude 7280

## Testing Strategy

### Comprehensive Testing Checklist
- [ ] System boots properly
- [ ] All hardware components detected
- [ ] Network connectivity works
- [ ] Desktop environment launches
- [ ] YubiKey integration functions
- [ ] Audio/video setup operational
- [ ] Container platform ready
- [ ] Secrets management working
- [ ] Development tools available

### Validation Commands
```bash
# Hardware detection
lspci
lsusb
lscpu

# Filesystem verification
df -h
lsblk
btrfs filesystem show  # Latitude only

# Service status
systemctl status
systemctl --user status

# YubiKey testing
ykman list
SSH_AUTH_SOCK=/run/user/1000/yubikey-agent/yubikey-agent.sock ssh-add -L

# Audio/video testing
pactl info
v4l2-ctl --list-devices
```

## Future Enhancements

### Planned Features
- [ ] Impermanence integration with btrfs snapshots
- [ ] Automated snapshot management with btrbk
- [ ] Multi-boot configuration support
- [ ] Hardware detection and auto-profile selection
- [ ] Custom ISO builder with embedded configuration

### Additional Platforms
- [ ] Framework Laptop support
- [ ] ThinkPad series integration
- [ ] Desktop workstation profiles
- [ ] ARM-based system support

This platform abstraction provides a solid foundation for managing multiple NixOS systems while maintaining the excellent professional setup you've developed.