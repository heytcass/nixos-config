# NixOS Configuration

[![Build NixOS Configuration](https://github.com/heytcass/nixos-config/workflows/Build%20NixOS%20Configuration/badge.svg)](https://github.com/heytcass/nixos-config/actions/workflows/build.yml)

Personal NixOS configuration using flakes for reproducible system management with automated maintenance.

## 🖥️ System Overview

- **Host**: Dell XPS 13 9370 (`gti`)
- **Desktop**: GNOME with GDM
- **Kernel**: Latest Linux kernel
- **Boot**: systemd-boot with Plymouth splash
- **Package Manager**: Nix with flakes enabled

## 📁 Repository Structure

```
├── flake.nix                      # Main flake configuration
├── flake.lock                     # Locked dependency versions
├── hosts/
│   └── gti/
│       ├── configuration.nix      # System-level NixOS config
│       └── hardware-configuration.nix  # Hardware-specific settings
├── home/
│   └── tom/
│       └── home.nix               # User-level Home Manager config
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

### Modern Unix Tools
Includes modern CLI replacements with convenient aliases:
- `bat` → `cat` (syntax highlighting)
- `eza` → `ls` (colors and icons)
- `fd` → `find` (faster search)
- `procs` → `ps` (better formatting)
- `bottom` → `top` (system monitoring)
- `yazi` (terminal file manager)

### System Configuration
- **Colemak keyboard layout**
- **Auto-optimization** enabled (weekly store optimization)
- **Latest kernel** for hardware compatibility
- **Wayland optimization** with OZONE flags
- **Curated GNOME** with unnecessary apps removed

### Development Environment
- **Git** with SSH agent
- **GitHub CLI** (`gh`) configured
- **VS Code** and development tools
- **Modern fonts** (Nerd Fonts collection)

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

### Modifying Services
- Edit the `services` section in `hosts/gti/configuration.nix`
- Rebuild and switch to apply changes

### Hardware Changes
- Regenerate hardware config: `nixos-generate-config`
- Update `hosts/gti/hardware-configuration.nix` as needed

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