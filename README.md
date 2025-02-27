# Tom's NixOS Configuration

This repository contains my personal NixOS configuration using the Flakes feature.

## System Overview

- Host: gti
- Desktop: GNOME
- Keyboard Layout: Colemak (US)

## Usage

### Build and activate the configuration

```bash
# Apply system configuration
sudo nixos-rebuild switch --flake .#gti
```

### Update system

```bash
# Pull the latest changes
git pull

# Update flake inputs
nix flake update

# Apply updates
sudo nixos-rebuild switch --flake .#gti
```

### Adding new packages

Edit `home.nix` to add user packages or `configuration.nix` for system-wide packages.

## Structure

- `flake.nix`: Entry point for the flake configuration
- `configuration.nix`: System-wide configuration
- `home.nix`: User-specific configuration managed by Home Manager
- `hardware-configuration.nix`: Hardware-specific configuration (not tracked by git)
