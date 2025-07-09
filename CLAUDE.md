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
- **Development shell**: `nix develop` (includes nixd, nil, statix, deadnix, sops, age, nixfmt-rfc-style)
- **Build Home Manager standalone**: `nix build .#homeConfigurations."tom@gti"`
- **Update flake inputs**: `nix flake update`
- **Check flake**: `nix flake check`
- **Garbage collect**: `sudo nix-collect-garbage -d` (remove old generations)
- **List generations**: `sudo nix-env -p /nix/var/nix/profiles/system --list-generations`

### Git Workflow and Committing Changes

**IMPORTANT**: When asked to commit and push changes, use one of these workflows to avoid duplicate commits from pre-commit hooks:

#### Option 1: Recommended for Most Cases
```bash
git add .
git commit -m "Commit message"
git push
```

#### Option 2: For Only Modified Files (no new files)
```bash
git commit -am "Commit message"
git push
```

#### Option 3: Using the Helper Script
```bash
./scripts/git-commit-clean.sh "Commit message"
git push
```

**Key Points**:
- Pre-commit hooks automatically format and lint files, which can create unstaged changes
- `git commit -am` only stages **tracked** files, not new files
- `git add .` stages everything (new and modified files)
- Always check `git status` to verify clean state after commit
- The helper script handles formatting before commit to avoid hook conflicts

### Configuration Structure
This is a sophisticated modular flake-based NixOS configuration with an **intelligent mixin system** supporting multiple hosts with advanced conditional feature loading.

**Key Architecture:**
- `flake.nix` - Main entry point with helper functions for DRY system generation and desktop parameter assignment
- `lib/helpers.nix` - Advanced helper functions for system creation, type detection, and conditional package loading
- `nixos/default.nix` - Base NixOS configuration with sophisticated conditional mixin imports based on system type and desktop choice
- `nixos/_mixins/` - Modular feature-based configuration components:
  - `services/base.nix` - Core system configuration with performance optimizations and conditional loading
  - `services/stylix.nix` - Unified theming system with Claude-inspired color scheme
  - `services/secrets.nix` - SOPS-nix integration for secure secrets management
  - `services/claude-mcp.nix` - Declarative Claude MCP server configuration with SOPS integration
  - `desktop/` - Multiple desktop environments (GNOME, Hyprland, Niri) with conditional loading
  - `features/development.nix` - Development tools including Claude Desktop integration
  - `features/gaming.nix` - Gaming stack (workstation only with automatic detection)
  - `features/rust-utils.nix` - Modern Rust utility replacements with fallback aliases
  - `services/users.nix` - User account configuration with conditional packages
- `hosts/<hostname>/` - Host-specific configurations:
  - `configuration.nix` - Minimal host-specific settings and desktop assignment
  - `hardware-configuration.nix` - Auto-generated hardware settings
  - `disko-config.nix` - Declarative disk management (transporter only)
- `home/tom/home.nix` - Comprehensive Home Manager configuration with desktop-conditional features
- `overlays/` - Package customizations and ISO optimizations
- `secrets/` - SOPS-encrypted secrets with age-based encryption
- `scripts/` - Helper scripts for deployment and maintenance

**Advanced Mixin System Benefits:**
- **Multi-Level Conditional Loading**: Features load based on system type (workstation/laptop/ISO), desktop choice (Hyprland/Niri/GNOME), and host-specific needs
- **DRY Architecture**: Helper functions eliminate configuration duplication across hosts
- **Intelligent Type Detection**: Automatic workstation/laptop/ISO detection with hostname-based feature sets
- **Desktop Environment Flexibility**: Per-host desktop assignment with conditional theming and optimization
- **Modular Design**: Easy to add/remove features without touching core configuration
- **Performance Optimization**: Conditional loading reduces build time and system resource usage

**Important Details:**
- Uses `home-manager.useGlobalPkgs = true` - do NOT set nixpkgs options in home.nix
- **Supported hosts:**
  - `gti`: Dell XPS 13 9370 (main workstation) - Hyprland desktop, gaming features included
  - `transporter`: Dell Latitude 7280 (secondary laptop) - Niri desktop, gaming features auto-excluded
  - `iso`: Live ISO configuration - no desktop environment, minimal terminal-only setup
- **System Type Detection**: Hostnames determine feature sets automatically
- Uses unstable nixpkgs channel for latest packages
- Each host uses appropriate nixos-hardware module for optimal hardware support
- System uses latest Linux kernel with desktop environment per host (Hyprland/Niri/none)
- Keyboard layout set to Colemak variant for ergonomic typing
- Plymouth boot splash enabled for smooth boot experience
- Wayland support optimized with NIXOS_OZONE_WL environment variable
- Git credential helper configured system-wide
- fwupd enabled for firmware updates
- Modern shell environment with Fish and enhanced Starship prompt
- Claude Desktop integration via custom flake input
- Stylix unified theming system with Claude-inspired color scheme
- SOPS-nix integration for secure secrets management
- Rust utilities replacing traditional GNU tools (sudo-rs, uutils)

**Desktop Environment Assignments:**
- **gti**: Hyprland wayland compositor with gaming optimizations
- **transporter**: Niri scrollable-tiling compositor for productivity
- **iso**: No desktop environment - terminal-only minimal setup

## Claude MCP Server Integration

### Configuration
- **Declarative management**: `nixos/_mixins/services/claude-mcp.nix`
- **SOPS integration**: Secrets encrypted and automatically injected
- **Single source of truth**: NixOS module generates Claude Desktop config
- **Current servers**: Home Assistant MCP and NixOS MCP only
- **File system access**: Uses Claude's built-in filesystem extension (no separate MCP server needed)

### Workflow
1. **Modify**: Edit `nixos/_mixins/services/claude-mcp.nix` for server changes
2. **Rebuild**: Run `sudo nixos-rebuild switch --flake .#<hostname>`
3. **Auto-generation**: Config file created with secrets from SOPS

**Security**: All MCP server secrets (Home Assistant token, etc.) are SOPS-encrypted and never stored in plaintext in the repository.

## Shell and CLI Environment

### Enhanced Terminal Experience
- **Primary shell**: Fish with Bash compatibility
- **Terminal**: Ghostty with Claude-inspired theming
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

### Rust Utility Replacements
- **sudo-rs**: Memory-safe sudo replacement with audit logging
- **uutils-coreutils**: Rust implementations of core utilities (ls, cat, mkdir, etc.)
- **uutils-findutils**: Rust implementations of find, xargs, locate
- **Comprehensive aliases**: Seamless fallback from Rust tools to traditional versions

### Git Configuration
- **User**: Tom Cassady (heytcass@gmail.com)
- **GitHub CLI**: Configured with SSH protocol
- **SSH agent**: Automatically started via Home Manager
- **Credential helper**: System-wide configuration for seamless authentication

## Unified Theming with Stylix

### Claude-Inspired Color Scheme
- **Base16 palette**: Custom colors matching Claude's visual identity
- **Primary colors**: Warm terracotta and earth tones
- **Typography**: JetBrains Mono, Inter, Source Serif Pro
- **Consistent theming**: Console, Plymouth, GTK, Qt applications

### Theming Targets
- **Console colors**: Terminal and TTY theming
- **Plymouth boot**: Coordinated splash screen colors
- **Desktop environments**: GTK/Qt theme integration
- **Selective enabling**: Avoids conflicts with custom application themes

## Common Tasks

### Package Management
- **Add system packages**: Edit the appropriate mixin in `nixos/_mixins/`:
  - `features/development.nix` for development tools
  - `features/gaming.nix` for gaming-related packages
  - `features/rust-utils.nix` for modern CLI tool replacements
  - `desktop/gnome.nix`, `desktop/hyprland.nix`, or `desktop/niri.nix` for desktop applications
  - `services/base.nix` for core system packages
- **Add user packages**: Edit `home.packages` in `home/tom/home.nix`
- **Host-specific packages**: Add directly to `hosts/<hostname>/configuration.nix` if needed
- **Add development tools**: Consider using `shell.nix` or `flake.nix` for project-specific environments

### Configuration Changes
- **Modify shared system services**: Edit services section in appropriate `nixos/_mixins/services/` file
- **Host-specific services**: Edit services section in `hosts/<hostname>/configuration.nix`
- **Update shell aliases**: Edit `programs.fish.shellAliases` or `programs.bash.shellAliases` in `home/tom/home.nix`
- **Customize starship prompt**: Edit `programs.starship.settings` in `home/tom/home.nix`
- **Change hardware**: Regenerate `hardware-configuration.nix` with `nixos-generate-config` for specific host
- **Add new host**: Create new directory in `hosts/` and add configuration to `flake.nix`

### Storage Management (Disko + Btrfs)
- **Transporter host**: Uses declarative disk partitioning via Disko
- **Btrfs features**: Compression (zstd), subvolumes, auto-scrubbing
- **Subvolume layout**: Separate subvolumes for root, home, nix, snapshots
- **Snapshot management**: Automatic cleanup and retention policies
- **Commands**:
  - `sudo btrfs subvolume snapshot /home /home/.snapshots/$(date +%Y%m%d-%H%M%S)`
  - `sudo btrfs scrub start /`
  - `sudo btrfs filesystem show`

## SOPS Secrets Management

### Infrastructure
- **Encryption**: Age-based encryption with SOPS
- **Storage**: Encrypted secrets in `secrets/secrets.yaml`
- **Access control**: Host-specific decryption keys
- **Integration**: Automatic secret deployment during rebuild

### Workflow
- **Edit secrets**: `sops secrets/secrets.yaml`
- **Add new secrets**: Update `secrets.yaml` with proper structure
- **Deploy secrets**: Automatically handled during `nixos-rebuild switch`
- **Key management**: Age keys stored in `/etc/sops/age/keys.txt`

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
├── nixos/_mixins/               # Modular configuration mixins
│   ├── services/                # System services
│   │   ├── base.nix             # Core system configuration
│   │   ├── users.nix            # User account configuration
│   │   ├── tailscale.nix        # Tailscale VPN service
│   │   ├── secrets.nix          # SOPS secrets management
│   │   ├── stylix.nix           # Unified theming system
│   │   └── claude-mcp.nix       # Claude MCP server configuration
│   ├── features/                # Optional features
│   │   ├── development.nix      # Development tools and environment
│   │   ├── gaming.nix           # Gaming-specific packages and settings
│   │   └── rust-utils.nix       # Modern Rust utility replacements
│   └── desktop/                 # Desktop environments
│       ├── gnome.nix            # GNOME desktop environment
│       ├── hyprland.nix         # Hyprland wayland compositor
│       └── niri.nix             # Niri scrollable-tiling compositor
├── home/tom/                    # User Home Manager configuration
│   ├── home.nix                 # User environment shared across hosts
│   ├── desktop/                 # Desktop-specific user configs
│   └── secrets/                 # User secrets (git-ignored)
├── lib/                         # Helper functions
│   ├── default.nix              # Library exports
│   └── helpers.nix              # System creation helpers
├── overlays/                    # Package customizations
│   ├── default.nix              # Overlay exports
│   └── iso-optimizations.nix    # ISO-specific optimizations
├── secrets/                     # System secrets (SOPS-encrypted)
│   ├── secrets.yaml            # Encrypted secrets storage
│   └── README.md               # Secrets management documentation
├── scripts/                     # Deployment and utility scripts
│   └── git-commit-clean.sh      # Automated formatting and commit script
├── CLAUDE.md                    # This file
└── README.md                    # Project documentation
```

# important-instruction-reminders
Do what has been asked; nothing more, nothing less.
NEVER create files unless they're absolutely necessary for achieving your goal.
ALWAYS prefer editing an existing file to creating a new one.
NEVER proactively create documentation files (*.md) or README files. Only create documentation files if explicitly requested by the User.
