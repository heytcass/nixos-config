# NixOS Configuration

[![NixOS Configuration](https://github.com/heytcass/nixos-config/workflows/Build%20NixOS%20Configuration/badge.svg)](https://github.com/heytcass/nixos-config/actions/workflows/build.yml)

Personal NixOS configuration using flakes for reproducible system management with automated maintenance and a modern development environment.

## 🖥️ System Overview

- **Host**: Dell XPS 13 9370 (`gti`) with nixos-hardware optimization
- **Desktop**: GNOME with GDM and Wayland optimization
- **Kernel**: Latest Linux kernel with firmware updates (fwupd)
- **Boot**: systemd-boot with Plymouth splash screen
- **Package Manager**: Nix with flakes enabled on unstable channel
- **Keyboard**: Colemak layout for ergonomic typing
- **Shell**: Fish with enhanced Starship prompt and Nerd Font icons

## 📁 Repository Structure

```text
├── flake.nix                      # Main flake configuration with inputs
├── flake.lock                     # Locked dependency versions
├── hosts/gti/
│   ├── configuration.nix          # System-level NixOS configuration
│   └── hardware-configuration.nix # Auto-generated hardware settings
├── home/tom/
│   └── home.nix                   # User Home Manager configuration
├── CLAUDE.md                      # AI assistant guidance for this repo
├── README.md                      # This documentation
└── .github/workflows/             # Automated maintenance workflows
    ├── build.yml                  # Build validation
    ├── flake-checker.yml          # Dependency health checks
    └── update-flake-lock.yml      # Weekly dependency updates
```

## 🚀 Quick Start

### Building the Configuration

```bash
# Build system configuration
sudo nixos-rebuild switch --flake .#gti

# Build without switching (test first)
sudo nixos-rebuild build --flake .#gti

# Test configuration temporarily
sudo nixos-rebuild test --flake .#gti
```

### Managing Dependencies

```bash
# Update all flake inputs
nix flake update

# Check flake health
nix flake check

# Show flake outputs
nix flake show
```

## 🛠️ Key Features

### Enhanced Shell Environment

**Fish Shell** with automatic command aliases and **Starship Prompt** featuring:

- 🔋 Battery status with charging indicators
- 📁 Directory path with read-only lock icons  
- 🐙 Git branch with status symbols ( ,  ,  , etc.)
- 🐧 Nix shell detection with snowflake icon
- ⚡ Command duration tracking for long operations
- 🟢 Language detection (Node.js , Python , Rust , Go )
- 🐳 Docker context and ☸️ Kubernetes integration

### Modern Unix Tools

Includes modern CLI replacements with convenient aliases:

- `bat` → `cat` (syntax highlighting and paging)
- `eza` → `ls` (colors, icons, and tree view)
- `fd` → `find` (faster and more intuitive search)
- `procs` → `ps` (better formatting and filtering)
- `bottom` → `top` (advanced system monitoring)
- `gping` → `ping` (visual ping with graphs)
- `dua` → `du` (interactive disk usage analyzer)
- `yazi` (modern terminal file manager)
- `dogdns` → `dig` (modern DNS lookup)
- `bandwhich` (network usage by process)
- `hyperfine` (command-line benchmarking)

### System Configuration

- **Colemak keyboard layout** for ergonomic typing
- **Auto-optimization** enabled (weekly Nix store optimization)
- **Latest kernel** with hardware-specific optimizations
- **Wayland optimization** with NIXOS_OZONE_WL environment variables
- **Curated GNOME** with unnecessary applications removed
- **fwupd integration** for automatic firmware updates
- **Build caching** for faster rebuilds

### Development Environment

- **Git** with system-wide credential helper and SSH agent
- **GitHub CLI** (`gh`) with SSH protocol configuration
- **VS Code** with extensions and settings
- **Nerd Fonts** collection for icon support in terminal
- **SSH agent** automatically started via Home Manager

## 🤖 Automated Maintenance

This repository includes GitHub Actions workflows for hands-off maintenance:

### Weekly Updates

- **Update Flake Lock**: Creates PRs every Sunday with dependency updates
- Automatically assigns PRs to repository owner
- Includes change summaries for easy review

### Continuous Integration

- **Build Validation**: Tests all configurations on push/PR
- **Flake Health Checks**: Validates dependency sources and freshness
- Ensures configurations always build successfully

### Security & Quality

- **Dependency Scanning**: Checks for outdated or unsupported inputs
- **Build Verification**: Validates both NixOS and Home Manager configs
- **Automated Testing**: Runs comprehensive checks on every change

## 📋 System Components

### Core System

- NixOS unstable channel
- Home Manager integration
- nixos-hardware Dell XPS 13 9370 module
- Auto-optimization enabled

### Desktop Environment

- GNOME desktop with extensions:
  - User Themes
  - AppIndicator
  - Vitals (system monitoring)
  - Pop Shell (tiling)
  - Blur My Shell (aesthetics)

### User Applications

- Bitwarden (password management)
- Google Chrome (web browsing)
- Slack (communication)
- Claude Code (AI-powered development)

## 🔧 Customization

### Adding Packages

- **System packages**: Edit `users.users.tom.packages` in `hosts/gti/configuration.nix`
- **User packages**: Edit `home.packages` in `home/tom/home.nix`
- **Development tools**: Consider project-specific `shell.nix` or `flake.nix` files

### Shell and Prompt Customization

- **Shell aliases**: Edit `programs.fish.shellAliases` or `programs.bash.shellAliases` in `home/tom/home.nix`
- **Starship prompt**: Modify `programs.starship.settings` in `home/tom/home.nix`
- **Fish configuration**: Update `programs.fish` settings for advanced shell features

### System Services

- **Modify services**: Edit the `services` section in `hosts/gti/configuration.nix`
- **Enable new features**: Add hardware or service modules to configuration
- **Apply changes**: Run `sudo nixos-rebuild switch --flake .#gti`

### Hardware Changes

- **Regenerate hardware config**: Run `nixos-generate-config`
- **Update settings**: Modify `hosts/gti/hardware-configuration.nix` as needed
- **Hardware modules**: Consider additional nixos-hardware modules for new devices

### Maintenance Commands

```bash
# Apply configuration changes
sudo nixos-rebuild switch --flake .#gti

# Update all dependencies  
nix flake update

# Clean up old generations
sudo nix-collect-garbage -d

# List system generations
sudo nix-env -p /nix/var/nix/profiles/system --list-generations
```

## 📚 Learning Resources

- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Home Manager Options](https://nix-community.github.io/home-manager/options.html)
- [Nix Flakes Guide](https://nixos.wiki/wiki/Flakes)
- [nixos-hardware Modules](https://github.com/NixOS/nixos-hardware)

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Ensure the build passes (GitHub Actions will test this)
5. Submit a pull request

The automated workflows will validate your changes and ensure they don't break the system configuration.

---

*This configuration is continuously maintained with automated dependency updates and build validation.*
