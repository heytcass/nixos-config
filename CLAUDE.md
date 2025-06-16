# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### System Management
- **Build and switch configuration**: 
  - `sudo nixos-rebuild switch --flake .#gti` (Dell XPS 13 9370 main workstation)
  - `sudo nixos-rebuild switch --flake .#transporter` (Dell Latitude 7280 secondary laptop)
- **Build without switching**: `sudo nixos-rebuild build --flake .#<hostname>`
- **Test configuration**: `sudo nixos-rebuild test --flake .#<hostname>`
- **Build ISO**: `nix build .#nixosConfigurations.iso.config.system.build.isoImage`
- **Development shell**: `nix develop` (includes nixd, nil, statix, deadnix, sops, age)
- **Build Home Manager standalone**: `nix build .#homeConfigurations."tom@gti"`
- **Update flake inputs**: `nix flake update`
- **Check flake**: `nix flake check`
- **Garbage collect**: `sudo nix-collect-garbage -d` (remove old generations)
- **List generations**: `sudo nix-env -p /nix/var/nix/profiles/system --list-generations`

### Configuration Structure
This is a modular flake-based NixOS configuration with a **mixin system** supporting multiple hosts with conditional feature loading.

**Key Architecture:**
- `flake.nix` - Main entry point with helper functions for DRY system generation
- `lib/helpers.nix` - Helper functions for consistent system creation and type detection
- `nixos/default.nix` - Base NixOS configuration with conditional mixin imports
- `nixos/_mixins/` - Modular feature-based configuration components:
  - `services/base.nix` - Core system configuration with conditional loading
  - `desktop/gnome.nix` - GNOME desktop environment (skipped for ISO)
  - `features/development.nix` - Development tools and environment
  - `features/gaming.nix` - Gaming stack (workstation only)
  - `services/users.nix` - User account configuration with conditional packages
- `hosts/<hostname>/configuration.nix` - Minimal host-specific settings
- `hosts/<hostname>/hardware-configuration.nix` - Auto-generated hardware settings
- `home/tom/home.nix` - User-specific Home Manager configuration
- `overlays/` - Package customizations and optimizations

**Mixin System Benefits:**
- **Conditional Loading**: Features automatically included/excluded based on system type
- **DRY Architecture**: Helper functions eliminate configuration duplication
- **Type Detection**: Automatic workstation/laptop/ISO detection for conditional features
- **Modular Design**: Easy to add/remove features without touching core configuration

**Important Details:**
- Uses `home-manager.useGlobalPkgs = true` - do NOT set nixpkgs options in home.nix
- **Supported hosts:**
  - `gti`: Dell XPS 13 9370 (main workstation) - automatically includes gaming features
  - `transporter`: Dell Latitude 7280 (secondary laptop) - gaming features auto-excluded
  - `iso`: Live ISO configuration - desktop/laptop features conditionally loaded
- **System Type Detection**: Hostnames determine feature sets automatically
- Uses unstable nixpkgs channel for latest packages
- Each host uses appropriate nixos-hardware module for optimal hardware support
- System uses latest Linux kernel and GNOME desktop with GDM
- Keyboard layout set to Colemak variant for ergonomic typing
- Plymouth boot splash enabled for smooth boot experience
- Wayland support optimized with NIXOS_OZONE_WL environment variable
- Git credential helper configured system-wide
- fwupd enabled for firmware updates
- Modern shell environment with Fish and enhanced Starship prompt
- Claude Desktop integration via custom flake input

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
  - `yazi` → terminal file manager
  - `dogdns` → modern dig replacement
  - `bandwhich` → network usage by process
  - `mtr` → better traceroute
  - `hyperfine` → command-line benchmarking
  - `tldr` → simplified man pages

### Git Configuration
- **User**: Tom Cassady (heytcass@gmail.com)
- **GitHub CLI**: Configured with SSH protocol
- **SSH agent**: Automatically started via Home Manager
- **Credential helper**: System-wide configuration for seamless authentication

## Common Tasks

### Package Management
- **Add system packages**: Edit the appropriate module in `modules/common/`:
  - `development.nix` for development tools
  - `gaming.nix` for gaming-related packages
  - `desktop.nix` for desktop applications
  - `base.nix` for core system packages
- **Add user packages**: Edit `home.packages` in `home/tom/home.nix`
- **Host-specific packages**: Add directly to `hosts/<hostname>/configuration.nix` if needed
- **Add development tools**: Consider using `shell.nix` or `flake.nix` for project-specific environments

### Configuration Changes
- **Modify shared system services**: Edit services section in appropriate `modules/common/` file
- **Host-specific services**: Edit services section in `hosts/<hostname>/configuration.nix`
- **Update shell aliases**: Edit `programs.fish.shellAliases` or `programs.bash.shellAliases` in `home/tom/home.nix`
- **Customize starship prompt**: Edit `programs.starship.settings` in `home/tom/home.nix`
- **Change hardware**: Regenerate `hardware-configuration.nix` with `nixos-generate-config` for specific host
- **Add new host**: Create new directory in `hosts/` and add configuration to `flake.nix`

### Maintenance
- **Apply changes**: Run `sudo nixos-rebuild switch --flake .#<hostname>` after any configuration edits
- **Update dependencies**: Run `nix flake update` to update all flake inputs
- **Build ISO**: Run `nix build .#nixosConfigurations.iso.config.system.build.isoImage`
- **Clean up**: Use `sudo nix-collect-garbage -d` to remove old generations and free disk space
- **Backup important data**: Configuration is in git, but backup `/home/tom` user data separately

## File Structure Overview
```
/home/tom/.nixos/
├── flake.nix                    # Main flake configuration with all hosts
├── flake.lock                   # Locked dependency versions
├── hosts/                       # Host-specific configurations
│   ├── gti/                     # Dell XPS 13 9370 (main workstation)
│   │   ├── configuration.nix    # Host-specific settings
│   │   └── hardware-configuration.nix  # Hardware-specific settings
│   ├── transporter/             # Dell Latitude 7280 (secondary laptop)
│   │   ├── configuration.nix    # Host-specific settings
│   │   └── hardware-configuration.nix  # Hardware-specific settings
│   └── iso/                     # Live ISO configuration
│       └── configuration.nix    # ISO-specific settings
├── modules/common/              # Shared configuration modules
│   ├── base.nix                 # Core system configuration
│   ├── desktop.nix              # GNOME desktop environment
│   ├── development.nix          # Development tools and environment
│   ├── gaming.nix               # Gaming-specific packages and settings
│   └── users.nix                # User account configuration
├── home/tom/                    # User Home Manager configuration
│   ├── home.nix                 # User environment shared across hosts
│   └── secrets/                 # User secrets (git-ignored)
├── CLAUDE.md                    # This file
└── README.md                    # Project documentation
```