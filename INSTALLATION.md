# Quick Installation Guide

## Direct Installation to Dell Latitude 7280

### One-Command Installation
```bash
# 1. Boot target machine from NixOS installer ISO
# 2. Enable SSH: sudo systemctl start sshd && sudo passwd nixos  
# 3. Check disk type: lsblk or fdisk -l (to see if /dev/sda or /dev/nvme0n1)
# 4. Install from your development machine:
nix run .#install-transporter <target-ip> [disk-device]

# Examples for Dell Latitude 7280:
nix run .#install-transporter 192.168.1.100                # SATA M.2 SSD (default)
nix run .#install-transporter 192.168.1.100 /dev/nvme0n1   # NVMe M.2 SSD
```

### What Happens Automatically
- 🔧 **Disk partitioning** with btrfs subvolumes and compression
- 📦 **Complete system installation** with all professional tools
- 🔐 **Secrets management** with automatic age key generation
- 🎵 **Audio/video setup** with EasyEffects and OBS Studio
- 🔑 **YubiKey services** ready for PIV/FIDO2 authentication
- 🐳 **Container platform** with rootless Podman
- ✅ **Post-install validation** on first boot

### After Installation (2 Manual Steps)
```bash
# SSH to new system
ssh tom@<target-ip>

# Generate YubiKey PIV SSH key (requires PIN/touch)
nix run .#setup-yubikey-piv

# Add the displayed SSH key to GitHub/GitLab
```

### Test Complete Setup
```bash
obs          # OBS Studio with virtual camera
easyeffects  # Professional audio processing
podman run hello-world  # Container platform
```

## Installation Features

### Dell Latitude 7280 (`transporter`)
- **Filesystem**: btrfs with compression and subvolumes
- **Hardware**: Optimized for Skylake architecture
- **Services**: All professional A/V and development tools
- **Automation**: Complete post-install setup included

### Comparison to Manual Installation
| Task | Manual Method | Automated Method |
|------|---------------|------------------|
| Disk partitioning | `fdisk` + manual setup | ✅ Declarative with disko |
| Base installation | `nixos-install` | ✅ One `nix run` command |
| Hardware optimization | Manual driver/kernel tweaks | ✅ nixos-hardware integration |
| Secrets management | Manual age key setup | ✅ Auto-generated from SSH |
| Audio/video setup | Manual configuration | ✅ Declarative via Home Manager |
| YubiKey services | Manual service setup | ✅ Automatic with post-install |
| Container platform | Manual podman setup | ✅ Rootless with user lingering |
| Development tools | Package-by-package | ✅ Complete professional suite |

## Time Comparison
- **Traditional NixOS install + manual setup**: ~2-4 hours
- **This automated approach**: ~15-30 minutes + 2 manual commands

## Safety Features
- ✅ **XPS 13 9370 completely protected** - separate configurations
- ✅ **Git branch isolation** - all work on `platform-expansion` 
- ✅ **Complete backup** - original configuration preserved
- ✅ **Rollback ready** - can revert all changes instantly
- ✅ **Hardware validation** - nixos-hardware compatibility

Your professional workstation setup, now deployable to any compatible hardware in minutes instead of hours.