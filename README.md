# NixOS Configuration

[![NixOS Configuration](https://github.com/heytcass/nixos-config/workflows/Build%20NixOS%20Configuration/badge.svg)](https://github.com/heytcass/nixos-config/actions/workflows/build.yml)

Personal NixOS configuration using flakes for reproducible system management with automated maintenance and a modern development environment.

## 🖥️ System Overview

This is a modular NixOS configuration supporting multiple hosts with shared configuration modules:

### Supported Hosts
- **gti**: Dell XPS 13 9370 (main workstation) with full desktop, gaming, and development setup
- **transporter**: Dell Latitude 7280 (secondary laptop) with desktop and development setup
- **iso**: Live ISO configuration for installation and recovery

### Common Features
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
├── hosts/                         # Host-specific configurations
│   ├── gti/                       # Dell XPS 13 9370 (main workstation)
│   │   ├── configuration.nix      # Host-specific settings
│   │   └── hardware-configuration.nix # Auto-generated hardware settings
│   ├── transporter/               # Dell Latitude 7280 (secondary laptop)
│   │   ├── configuration.nix      # Host-specific settings
│   │   └── hardware-configuration.nix # Auto-generated hardware settings
│   └── iso/                       # Live ISO configuration
│       └── configuration.nix      # ISO-specific settings
├── modules/common/                # Shared configuration modules
│   ├── base.nix                   # Core system configuration
│   ├── desktop.nix                # GNOME desktop environment
│   ├── development.nix            # Development tools and environment
│   ├── gaming.nix                 # Gaming-specific packages and settings
│   └── users.nix                  # User account configuration
├── home/tom/                      # User Home Manager configuration
│   ├── home.nix                   # User environment and packages
│   └── secrets/                   # User secrets (git-ignored)
├── CLAUDE.md                      # AI assistant guidance for this repo
├── README.md                      # This documentation
└── .github/workflows/             # Automated maintenance workflows
    ├── build.yml                  # Multi-host build validation
    ├── build-iso.yml              # ISO image build testing
    ├── claude.yml                 # Claude Desktop integration
    ├── flake-checker.yml          # Dependency health checks
    ├── gaming-validation.yml      # Gaming environment validation
    ├── security-audit.yml         # Security scanning
    └── update-flake-lock.yml      # Weekly dependency updates
```

## 🚀 Quick Start

### Building the Configuration

```bash
# Build system configuration for specific host
sudo nixos-rebuild switch --flake .#gti          # Main workstation
sudo nixos-rebuild switch --flake .#transporter # Secondary laptop

# Build without switching (test first)
sudo nixos-rebuild build --flake .#gti

# Test configuration temporarily
sudo nixos-rebuild test --flake .#gti

# Build ISO image
nix build .#nixosConfigurations.iso.config.system.build.isoImage
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

### Modular System Architecture

- **Shared modules** for consistent configuration across hosts
- **Host-specific customization** via individual configuration files
- **Colemak keyboard layout** for ergonomic typing
- **Auto-optimization** enabled (weekly Nix store optimization)
- **Latest kernel** with hardware-specific optimizations via nixos-hardware
- **Wayland optimization** with NIXOS_OZONE_WL environment variables
- **Curated GNOME** with unnecessary applications removed
- **fwupd integration** for automatic firmware updates
- **Gaming support** (optional per host via gaming.nix module)
- **Live ISO** for installation and system recovery

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

- **Multi-Host Build Validation**: Tests all host configurations on push/PR
- **ISO Build Testing**: Validates live ISO generation
- **Gaming Environment Validation**: Tests gaming-specific configurations
- **Flake Health Checks**: Validates dependency sources and freshness
- **Claude Desktop Integration**: Automated testing of AI development tools
- Ensures all configurations always build successfully

### Security & Quality

- **Security Auditing**: Regular vulnerability scanning of system packages
- **Dependency Scanning**: Checks for outdated or unsupported inputs
- **Multi-Host Build Verification**: Validates all host configurations and Home Manager configs
- **Comprehensive Testing**: Gaming, desktop, development environments tested automatically

## 📋 System Components

### Core System

- NixOS unstable channel
- Home Manager integration with shared user configuration
- nixos-hardware modules for Dell XPS 13 9370 and Dell Latitude 7280
- Modular architecture with shared common modules
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
- Claude Desktop (AI-powered development)
- VS Code (code editor)
- Gaming tools (protonup-qt for Steam/Proton management)

## 🔧 Customization

### Adding Packages

- **System packages**: Edit the appropriate module in `modules/common/` (e.g., `development.nix`, `gaming.nix`)
- **User packages**: Edit `home.packages` in `home/tom/home.nix`
- **Host-specific packages**: Add to individual host configurations if needed
- **Development tools**: Consider project-specific `shell.nix` or `flake.nix` files

### Shell and Prompt Customization

- **Shell aliases**: Edit `programs.fish.shellAliases` or `programs.bash.shellAliases` in `home/tom/home.nix`
- **Starship prompt**: Modify `programs.starship.settings` in `home/tom/home.nix`
- **Fish configuration**: Update `programs.fish` settings for advanced shell features

### System Services

- **Modify shared services**: Edit the appropriate module in `modules/common/`
- **Host-specific services**: Edit services in individual host configurations
- **Enable new features**: Add hardware or service modules to configuration
- **Apply changes**: Run `sudo nixos-rebuild switch --flake .#<hostname>`

### Hardware Changes

- **Regenerate hardware config**: Run `nixos-generate-config` and update appropriate host
- **Update settings**: Modify `hosts/<hostname>/hardware-configuration.nix` as needed
- **Hardware modules**: Add appropriate nixos-hardware modules to host configuration
- **New hosts**: Create new directory in `hosts/` and add to `flake.nix`

### Maintenance Commands

```bash
# Apply configuration changes (replace <hostname> with gti, transporter, etc.)
sudo nixos-rebuild switch --flake .#<hostname>

# Update all dependencies  
nix flake update

# Build ISO image
nix build .#nixosConfigurations.iso.config.system.build.isoImage

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
