# NixOS Configuration Documentation

*Comprehensive documentation of Tom's NixOS configuration*

---

## Executive Summary

This is a sophisticated, modular NixOS configuration designed for development, gaming, and daily computing across multiple devices. The configuration leverages Nix flakes for reproducible builds, Home Manager for user environment management, and comprehensive CI/CD automation for maintenance and security.

### Key Features
- **Multi-host support**: Two laptops plus live ISO configuration
- **Modern development environment**: Claude Desktop, modern CLI tools, optimized shell experience
- **Gaming capabilities**: Steam, GameMode, hardware-accelerated graphics
- **Performance optimization**: Custom kernel parameters, power management, I/O scheduling
- **Automated maintenance**: Weekly updates, security scanning, build validation
- **Live ISO distribution**: Automated builds with GitHub releases

### Supported Hardware
- **Primary**: Dell XPS 13 9370 (gti) - Full workstation with gaming
- **Secondary**: Dell Latitude 7280 (transporter) - Portable development laptop
- **Recovery**: Live ISO for installation and system recovery

---

## System Architecture

### Flake-Based Configuration
The configuration is built around a single `flake.nix` that defines:
- **Inputs**: nixpkgs (unstable), home-manager, nixos-hardware, claude-desktop
- **Outputs**: Three NixOS system configurations (gti, transporter, iso)
- **Dependency management**: Centralized with automatic weekly updates

### Modular Design
```
/home/tom/.nixos/
├── flake.nix                    # Main flake configuration
├── flake.lock                   # Dependency locks
├── hosts/                       # Host-specific configurations
│   ├── gti/                     # Dell XPS 13 9370
│   ├── transporter/             # Dell Latitude 7280
│   └── iso/                     # Live ISO
├── modules/common/              # Shared configuration modules
├── home/tom/                    # Home Manager configuration
├── overlays/                    # Package optimizations
└── .github/workflows/           # CI/CD automation
```

### Shared Module System
- **base.nix**: Core system, performance, power management
- **desktop.nix**: GNOME desktop environment
- **development.nix**: Development tools and environment
- **gaming.nix**: Gaming stack (optional per host)
- **users.nix**: User accounts and applications

---

## Core Dependencies Analysis

### Flake Inputs (from flake.lock)
```nix
{
  nixpkgs = {
    # NixOS unstable - latest packages
    lastModified = 1749794982;
    rev = "ee930f9755f58096ac6e8ca94a1887e0534e2d81";
  };
  
  home-manager = {
    # User environment management
    lastModified = 1749944797;
    rev = "c5f345153397f62170c18ded1ae1f0875201d49a";
  };
  
  nixos-hardware = {
    # Hardware-specific optimizations
    lastModified = 1749832440;
    rev = "db030f62a449568345372bd62ed8c5be4824fa49";
  };
  
  claude-desktop = {
    # AI-powered development environment
    lastModified = 1749693086;
    owner = "heytcass";
    repo = "claude-desktop-linux-flake";
  };
}
```

### Dependency Strategy
- **nixpkgs**: Uses unstable channel for latest features
- **home-manager**: Follows nixpkgs for compatibility
- **Hardware support**: Official NixOS hardware modules
- **Updates**: Automated weekly via GitHub Actions

---

## Host Configurations

### gti (Dell XPS 13 9370) - Main Workstation

**Location**: `hosts/gti/configuration.nix`

**Modules Imported**:
- hardware-configuration.nix (auto-generated)
- All common modules including gaming.nix
- Dell XPS 13 9370 hardware module

**Key Features**:
- Full gaming stack (Steam, GameMode)
- Complete development environment
- Hardware-optimized for Intel graphics
- System state version: 25.05

### transporter (Dell Latitude 7280) - Secondary Laptop

**Location**: `hosts/transporter/configuration.nix`

**Modules Imported**:
- hardware-configuration.nix (auto-generated)
- Common modules excluding gaming.nix
- Dell Latitude 7280 hardware module

**Key Features**:
- Development-focused configuration
- No gaming packages (portable/battery optimized)
- Same user environment via Home Manager
- System state version: 25.05

### iso - Live Installation/Recovery Environment

**Location**: `hosts/iso/configuration.nix`

**Key Features**:
- Minimal ISO based on NixOS installation-cd-minimal
- GNOME desktop with Colemak layout
- Essential tools for system recovery
- Passwordless sudo for convenience
- Live user: `tom` (password: `nixos`)
- Modern CLI tools included
- Size-optimized with custom overlays

**ISO Configuration**:
- Volume ID: NIXOS_TOM
- EFI and USB bootable
- SSH enabled for remote access
- NetworkManager for connectivity

---

## System Modules Deep Dive

### base.nix - Core System Configuration

**Boot Configuration**:
- Latest Linux kernel (`pkgs.linuxPackages_latest`)
- systemd-boot with 2-second timeout
- Plymouth boot splash (breeze theme)
- Optimized kernel parameters for Intel graphics and performance

**Performance Optimizations**:
```nix
kernelParams = [
  "i915.enable_guc=2"           # Intel GuC/HuC firmware
  "i915.enable_fbc=1"           # Framebuffer compression
  "transparent_hugepage=madvise" # Memory management
  "numa_balancing=enable"       # Multi-core optimization
];

kernel.sysctl = {
  "vm.swappiness" = 10;         # Prefer RAM over swap
  "net.ipv4.tcp_congestion_control" = "bbr"; # Network performance
  "fs.inotify.max_user_watches" = 524288;    # File watching
};
```

**Power Management**:
- TLP with Intel P-State driver
- Powertop integration
- Battery charge thresholds (40-80%)
- Thermal management (thermald)
- CPU frequency scaling optimization

**Storage Optimization**:
- NVMe: No I/O scheduler (hardware queuing)
- SSD: mq-deadline scheduler
- Zram swap (50% RAM, lz4 compression)
- tmpfs for /tmp (2GB)
- noatime filesystem option

**System Services**:
- Firmware updates (fwupd)
- Automatic garbage collection (weekly, 30d retention)
- Store optimization
- IRQ balancing for multi-core performance

### desktop.nix - GNOME Desktop Environment

**Desktop Stack**:
- GNOME desktop with GDM display manager
- Colemak keyboard layout
- Wayland optimization via environment variables

**Fonts**:
- Nerd Fonts: FiraCode, JetBrains Mono, Hack
- Full Unicode support for shell prompts

**GNOME Customization**:
- Removed unnecessary apps (Maps, Music, Tour, etc.)
- Essential extensions: User Themes, AppIndicator, Vitals, Pop Shell, Blur My Shell
- Printing disabled by default (laptop optimization)

### development.nix - Development Environment

**Core Tools**:
- Fish shell system-wide
- Git with credential helper
- Claude Desktop with FHS environment for MCP servers
- Essential utilities: curl, wget, micro, yubikey-manager

**Integration**:
- Claude Desktop includes FHS wrapper for MCP server compatibility
- System-wide git credential management
- Development tools accessible across all hosts

### gaming.nix - Gaming Stack (gti only)

**Steam Configuration**:
- Steam with GameScope session
- Remote play, dedicated server, and local network transfers
- Firewall exceptions for gaming services

**Performance**:
- GameMode with process renicing
- Increased memory map count for games (`vm.max_map_count = 2147483642`)

**Note**: Only imported by gti host for battery optimization on transporter

### users.nix - User Account Management

**User Configuration**:
- User: tom (Tom Cassady)
- Groups: networkmanager, wheel, dialout
- Shell: Fish
- Common applications across both laptops

**User Applications**:
- Productivity: Apostrophe, Bitwarden, Todoist
- Development: Claude Code
- Communication: Discord, Slack, Zoom
- Media: Spotify
- Browser: Google Chrome
- Hardware: Boatswain (Stream Deck control)

---

## Home Manager Configuration

**Location**: `home/tom/home.nix`

### User Environment
- Username: tom
- Home directory: /home/tom
- State version: 25.05
- SSH agent enabled

### Modern CLI Tools
Complete replacement of traditional Unix tools:
```nix
shellAliases = {
  cat = "bat";           # Syntax highlighting
  ls = "eza";            # Colors and icons
  find = "fd";           # Modern find
  ps = "procs";          # Better process viewer
  top = "btm";           # Enhanced system monitor
  dig = "dog";           # Modern DNS lookup
  ping = "gping";        # Real-time ping graphs
  du = "dua interactive"; # Visual disk usage
};
```

### Enhanced Shell Experience

**Starship Prompt Configuration**:
- Git status with branch icons ( ,  ,  )
- Language detection (Node.js , Python , Rust , Go )
- Battery indicator with charging states
- Command duration tracking
- Nix shell detection with snowflake icon
- Directory path with read-only indicators
- Time display and custom character styling

**Shell Support**:
- Fish as primary shell
- Bash compatibility maintained
- Consistent aliases across both shells

### Development Configuration

**Git Setup**:
- Name: Tom Cassady
- Email: heytcass@gmail.com
- SSH protocol for GitHub CLI

**Editor Configuration**:
- Primary editor: micro
- Environment variables set for EDITOR, SYSTEMD_EDITOR, VISUAL

**Gaming Environment**:
- Steam compatibility tools path configured
- ProtonUp-Qt for Proton version management

### XDG Integration
- Terminal applications hidden from launcher (bottom, yazi, fish, micro)
- Clean desktop application menu

---

## Automation & CI/CD Pipeline

### Overview
Seven GitHub Actions workflows provide comprehensive automation:

### 1. build.yml - Core Build Validation
**Triggers**: Push/PR to main, manual dispatch
**Purpose**: Validates NixOS configuration builds
**Key Actions**:
- Maximizes build space (`wimpysworld/nothing-but-nix`)
- Runs `nix flake check --all-systems`
- Builds gti system configuration
- Validates Home Manager configuration

### 2. claude.yml - AI Integration
**Triggers**: Comments/issues/PRs containing `@claude`
**Purpose**: Enables AI-powered code assistance
**Configuration**: Requires `ANTHROPIC_API_KEY` secret

### 3. flake-checker.yml - Dependency Health
**Triggers**: Changes to flake files, manual dispatch
**Purpose**: Validates flake health and security
**Checks**:
- Outdated inputs (30-day threshold)
- Input ownership verification
- Supported branch usage

### 4. gaming-validation.yml - Gaming Stack Testing
**Triggers**: Gaming-related file changes, weekly schedule (Fridays 8 AM UTC)
**Purpose**: Comprehensive gaming configuration validation
**Validations**:
- Steam configuration and firewall settings
- GameMode enablement and packages
- Graphics hardware acceleration
- Home Manager gaming tools
- Performance environment settings
**Hardware**: Specific to Dell XPS 13 9370

### 5. security-audit.yml - Security Scanning
**Triggers**: Weekly schedule (Tuesdays 7 AM UTC), security file changes
**Purpose**: Comprehensive security audit
**Actions**:
- Vulnerability scanning with vulnix
- Insecure package auditing
- License compliance checking
- Security report generation
**Retention**: 30-day artifact storage

### 6. update-flake-lock.yml - Dependency Updates
**Triggers**: Weekly schedule (Sundays 6 AM UTC), manual dispatch
**Purpose**: Automated dependency updates
**Process**: Creates PRs with updated flake.lock, auto-assigns to owner

### 7. build-iso.yml - ISO Build and Release
**Triggers**: Push to main (Nix file changes), manual dispatch
**Purpose**: Builds and releases NixOS Live ISO
**Features**:
- Resource monitoring during 60-minute build
- Checksum generation (SHA256, MD5)
- GitHub release creation with detailed notes
- 30-day artifact retention
**Integrations**: Cachix, FlakeHub cache, DeterminateSystems tools

---

## Advanced Features

### Performance Optimizations

**Boot Process**:
- Plymouth splash screen for clean boot experience
- Reduced console log levels
- Optimized systemd timeouts
- Intel graphics GuC/HuC firmware loading

**Memory Management**:
- Zram swap with lz4 compression (50% RAM)
- Transparent hugepages with madvise
- Reduced swappiness (prefer RAM)
- Optimized VFS cache pressure

**I/O Optimization**:
- NVMe: None scheduler (native queuing)
- SSD: mq-deadline scheduler
- tmpfs for /tmp (2GB allocation)
- noatime filesystem mount option

**Network Performance**:
- BBR congestion control
- fq queueing discipline
- Optimized buffer sizes

### Security Configurations

**System Hardening**:
- Intel IOMMU enabled
- Microcode updates enabled
- Firmware update automation (fwupd)
- Real-time kit for audio (rtkit)

**Automated Security**:
- Weekly vulnerability scanning
- License compliance monitoring
- Insecure package auditing
- Security artifact retention

### ISO Build System

**Package Optimizations** (`overlays/iso-optimizations.nix`):
- espeak: Disabled mbrola support (-650MB)
- git: Minimal configuration (no manual, no Python)
- GStreamer: Disabled heavy optional features

**Build Process**:
- Resource monitoring during build
- Conservative optimization approach
- Checksum verification
- Automated release management

---

## Maintenance & Operations

### Build Commands

**System Deployment**:
```bash
# Dell XPS 13 9370 (main workstation)
sudo nixos-rebuild switch --flake .#gti

# Dell Latitude 7280 (secondary laptop)
sudo nixos-rebuild switch --flake .#transporter

# Test configuration without switching
sudo nixos-rebuild test --flake .#<hostname>

# Build without applying
sudo nixos-rebuild build --flake .#<hostname>
```

**ISO Building**:
```bash
# Build live ISO
nix build .#nixosConfigurations.iso.config.system.build.isoImage

# Check flake health
nix flake check

# Update dependencies
nix flake update
```

**Maintenance**:
```bash
# Garbage collection
sudo nix-collect-garbage -d

# List generations
sudo nix-env -p /nix/var/nix/profiles/system --list-generations
```

### Update Strategy

**Automated Updates**:
- Flake dependencies: Weekly (Sundays 6 AM UTC)
- Security scanning: Weekly (Tuesdays 7 AM UTC)
- Gaming validation: Weekly (Fridays 8 AM UTC)

**Manual Updates**:
- Apply dependency updates after PR review
- Test configuration changes locally before merge
- Monitor CI/CD pipeline for failures

### Troubleshooting

**Common Issues**:
1. **Build failures**: Check GitHub Actions for detailed logs
2. **Hardware detection**: Regenerate hardware-configuration.nix
3. **Boot issues**: Use live ISO for recovery
4. **Performance**: Review TLP settings and kernel parameters

**Recovery Procedures**:
1. Boot from live ISO
2. Mount existing system
3. Enter nix-shell with git and nixos-rebuild
4. Apply configuration or roll back

---

## Configuration Management

### File Structure Best Practices

**Adding System Packages**:
- Development tools → `modules/common/development.nix`
- Gaming packages → `modules/common/gaming.nix`
- Desktop applications → `modules/common/desktop.nix`
- Core system → `modules/common/base.nix`

**Adding User Packages**:
- Edit `home.packages` in `home/tom/home.nix`
- Use Home Manager for user-specific configuration

**Host-Specific Configuration**:
- Add to `hosts/<hostname>/configuration.nix`
- Import additional modules as needed

### Adding New Hosts

1. Create directory: `hosts/<hostname>/`
2. Generate hardware configuration: `nixos-generate-config`
3. Create `configuration.nix` importing appropriate modules
4. Add host to `flake.nix` outputs
5. Update CI/CD workflows if needed

### Package Management Strategy

**System-Level**:
- Core functionality in common modules
- Hardware-specific in host configurations
- Security-focused package selection

**User-Level**:
- Development tools via Home Manager
- Modern CLI replacements with aliases
- Cross-shell compatibility maintained

**Optimization**:
- ISO-specific overlays for size reduction
- Performance-focused package selection
- Regular dependency updates

---

## Development Environment Integration

### Claude Desktop Integration
- FHS wrapper for MCP server compatibility
- Available on all hosts via development.nix
- Integrated with system-wide configuration

### Modern Toolchain
- Fish shell with enhanced prompt
- Modern Unix tool replacements
- Consistent aliases across shells
- Git and SSH configuration

### Hardware Support
- Intel graphics optimization
- Power management tuning
- Thermal management
- Laptop-specific optimizations

---

*This documentation reflects the configuration state as of the analysis date. For the most current information, refer to the source files and CI/CD pipeline status.*