# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### System Management
- **Build and switch configuration**: `sudo nixos-rebuild switch --flake .#gti`
- **Build without switching**: `sudo nixos-rebuild build --flake .#gti`
- **Test configuration**: `sudo nixos-rebuild test --flake .#gti`
- **Update flake inputs**: `nix flake update`
- **Check flake**: `nix flake check`
- **Garbage collect**: `sudo nix-collect-garbage -d` (remove old generations)
- **List generations**: `sudo nix-env -p /nix/var/nix/profiles/system --list-generations`

### Configuration Structure
This is a flake-based NixOS configuration for the "gti" host using Home Manager integration.

**Key Architecture:**
- `flake.nix` - Main entry point defining inputs (nixpkgs, home-manager, nixos-hardware) and system configuration
- `hosts/gti/configuration.nix` - System-level NixOS configuration (services, users, packages)
- `hosts/gti/hardware-configuration.nix` - Auto-generated hardware-specific settings (do not edit manually)
- `home/tom/home.nix` - User-specific Home Manager configuration with modern CLI tools and enhanced shell setup

**Important Details:**
- Uses `home-manager.useGlobalPkgs = true` - do NOT set nixpkgs options in home.nix
- Targets Dell XPS 13 9370 with nixos-hardware module for optimal hardware support
- Uses unstable nixpkgs channel for latest packages
- System uses latest Linux kernel and GNOME desktop with GDM
- Keyboard layout set to Colemak variant for ergonomic typing
- Plymouth boot splash enabled for smooth boot experience
- Wayland support optimized with NIXOS_OZONE_WL environment variable
- Git credential helper configured system-wide
- fwupd enabled for firmware updates
- Modern shell environment with Fish and enhanced Starship prompt

**Service Configuration Updates:**
- Use `services.displayManager.gdm.enable` (not `services.xserver.displayManager.gdm.enable`)
- Use `services.desktopManager.gnome.enable` (not `services.xserver.desktopManager.gnome.enable`)

## Shell and CLI Environment

### Enhanced Terminal Experience
- **Primary shell**: Fish with Bash compatibility
- **Prompt**: Starship with Nerd Font glyphs including:
  - Git status with branch/status icons ( ,  ,  , etc.)
  - Language detection (Node.js , Python , Rust , Go )
  - Battery indicator with charging states
  - Command duration tracking
  - Nix shell detection with snowflake icon
  - Directory path with read-only indicators
- **Modern CLI tools** (aliased automatically):
  - `bat` → better cat with syntax highlighting
  - `eza` → modern ls with colors and icons
  - `fd` → modern find replacement
  - `procs` → enhanced ps with better formatting
  - `bottom` → advanced system monitor
  - `gping` → ping with real-time graphs
  - `dua` → visual disk usage analyzer

### Git Configuration
- **User**: Tom Cassady (heytcass@gmail.com)
- **GitHub CLI**: Configured with SSH protocol
- **SSH agent**: Automatically started via Home Manager
- **Credential helper**: System-wide configuration for seamless authentication

## Common Tasks

### Package Management
- **Add system packages**: Edit `users.users.tom.packages` in `hosts/gti/configuration.nix`
- **Add user packages**: Edit `home.packages` in `home/tom/home.nix`
- **Add development tools**: Consider using `shell.nix` or `flake.nix` for project-specific environments

### Configuration Changes
- **Modify system services**: Edit services section in `hosts/gti/configuration.nix`
- **Update shell aliases**: Edit `programs.fish.shellAliases` or `programs.bash.shellAliases` in `home/tom/home.nix`
- **Customize starship prompt**: Edit `programs.starship.settings` in `home/tom/home.nix`
- **Change hardware**: Regenerate `hardware-configuration.nix` with `nixos-generate-config`

### Maintenance
- **Apply changes**: Run `sudo nixos-rebuild switch --flake .#gti` after any configuration edits
- **Update dependencies**: Run `nix flake update` to update all flake inputs
- **Clean up**: Use `sudo nix-collect-garbage -d` to remove old generations and free disk space
- **Backup important data**: Configuration is in git, but backup `/home/tom` user data separately

## File Structure Overview
```
/home/tom/.nixos/
├── flake.nix                    # Main flake configuration
├── flake.lock                   # Locked dependency versions
├── hosts/gti/
│   ├── configuration.nix        # System configuration
│   └── hardware-configuration.nix  # Hardware-specific settings
├── home/tom/
│   └── home.nix                 # User environment configuration
├── CLAUDE.md                    # This file
└── README.md                    # Project documentation
```