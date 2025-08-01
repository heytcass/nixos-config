# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Git Workflow

**CRITICAL**: This system uses YubiKey GPG signing. For automated commits, always use:
```bash
git cc-commit-msg "your commit message"
```
Never use regular `git commit` as it requires physical YubiKey touch interaction.

## Build and Deployment Commands

```bash
# Rebuild system configuration
rebuild

# Rebuild with package updates  
sudo nixos-rebuild switch --upgrade --flake ~/.nixos#gti

# Test configuration without switching
sudo nixos-rebuild test --flake ~/.nixos#gti

# Build configuration without applying
sudo nixos-rebuild build --flake ~/.nixos#gti

# Enter development shell with build tools
nix develop
```

## Architecture Overview

This is a modular NixOS configuration following DRY principles with the following key components:

### Core Structure
- **flake.nix**: Main flake with inputs (nixpkgs, home-manager, sops-nix, custom flakes)
- **configuration.nix**: System-level configuration importing all modules
- **home.nix**: User-level configuration via home-manager
- **modules/shared.nix**: Central DRY constants (user info, hardware specs, performance settings)

### Module Organization
- **modules/boot.nix**: Boot loader, kernel parameters, memory management sysctls
- **modules/hardware.nix**: Dell XPS 13 9370 specific optimizations
- **modules/desktop.nix**: GNOME desktop environment with Wayland
- **modules/networking.nix**: NetworkManager with DNS-over-TLS
- **modules/security.nix**: AppArmor, fail2ban, auditd, YubiKey support (pcscd)
- **modules/performance.nix**: Storage optimization, zram, udev rules
- **modules/tools.nix**: Modern CLI tools (Rust-based), YubiKey packages, Fish shell config
- **modules/systemd.nix**: SystemD services and user session configuration
- **modules/secrets.nix**: Sops-nix encrypted secrets management

### Key Integrations
- **Secrets Management**: sops-nix with age encryption for system and user secrets
- **YubiKey Integration**: GPG signing, PIV/FIDO2 authentication, touch requirements
- **Home Manager**: Declarative user environment with Fish shell, Starship prompt, modern tools
- **Custom Flakes**: notion-mac-flake, claude-desktop-linux-flake for additional packages

### Navigation Aliases
- `nixos` - Navigate to ~/.nixos directory
- `projects` - Navigate to ~/projects directory

## Development Notes

- Configuration uses shared constants from `modules/shared.nix` to avoid repetition
- All secrets are managed through sops-nix - never commit plain text secrets
- System targets Dell XPS 13 9370 with hardware-specific optimizations
- Fish shell with modern Rust-based CLI tools (eza, bat, fd, rg, etc.)
- GPG commit signing with YubiKey hardware security