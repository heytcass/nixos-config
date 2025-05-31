# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### System Management
- **Build and switch configuration**: `sudo nixos-rebuild switch --flake .#gti`
- **Build without switching**: `sudo nixos-rebuild build --flake .#gti`
- **Test configuration**: `sudo nixos-rebuild test --flake .#gti`
- **Update flake inputs**: `nix flake update`
- **Check flake**: `nix flake check`

### Configuration Structure
This is a flake-based NixOS configuration for the "gti" host using Home Manager integration.

**Key Architecture:**
- `flake.nix` - Main entry point defining inputs (nixpkgs, home-manager, nixos-hardware) and system configuration
- `hosts/gti/configuration.nix` - System-level NixOS configuration (services, users, packages)
- `hosts/gti/hardware-configuration.nix` - Auto-generated hardware-specific settings (do not edit manually)
- `home/tom/home.nix` - User-specific Home Manager configuration

**Important Details:**
- Uses `home-manager.useGlobalPkgs = true` - do NOT set nixpkgs options in home.nix
- Targets Dell XPS 13 9370 with nixos-hardware module
- Uses unstable nixpkgs channel
- System uses latest Linux kernel and GNOME desktop with GDM
- Keyboard layout set to Colemak variant
- Plymouth boot splash enabled
- Wayland support optimized with NIXOS_OZONE_WL environment variable

**Service Configuration Updates:**
- Use `services.displayManager.gdm.enable` (not `services.xserver.displayManager.gdm.enable`)
- Use `services.desktopManager.gnome.enable` (not `services.xserver.desktopManager.gnome.enable`)

## Common Tasks
- **Add system packages**: Edit `users.users.tom.packages` in configuration.nix
- **Add user packages**: Edit `home.packages` in home/tom/home.nix
- **Modify services**: Edit services section in configuration.nix
- **Change hardware**: Regenerate hardware-configuration.nix with `nixos-generate-config`