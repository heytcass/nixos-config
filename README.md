# NixOS Configuration

Modern, modular NixOS configuration with secure boot capabilities, advanced tooling, and complete home-manager integration.

## 🏗️ Architecture

- **Modular Design**: Clean separation of concerns across focused modules
- **Typed Options**: Custom `mySystem.*` options with proper validation via `modules/options.nix`
- **Secure by Default**: Hardware security, encrypted secrets, TPM2 support
- **Professional Workflow**: Modern CLI tools, development environments, communication stack

## 🚀 Features

### Phase 1 & 2: Security & Productivity ✅
- **Security Hardening**: CPU mitigations, AppArmor, fail2ban, YubiKey integration
- **Encrypted Secrets**: sops-nix with age encryption for all sensitive data
- **Professional Communication**: OBS Studio, EasyEffects, PipeWire low-latency audio
- **GNOME Productivity**: Optimized desktop with essential extensions
- **Modern CLI Stack**: Fish shell, Starship prompt, Rust-based tools (eza, bat, fd, rg)

### Phase 3: Architecture Migration ✅
- **Typed Configuration**: Migrated from shared constants to proper NixOS options
- **Future-Ready**: Foundation prepared for multi-system management
- **Type Safety**: All configuration values validated with proper types

### Phase 4: Advanced NixOS Tools ✅
- **Secure Boot Ready**: Lanzaboote integration (keys not enrolled by default)
- **TPM2 Support**: Hardware security for LUKS auto-unlock
- **Fast Builds**: nix-fast-build for parallel evaluation and building
- **Remote Deployment**: nixos-anywhere, colmena, and system analysis tools
- **Declarative Disk**: disko integration ready for disk partitioning

## 🖥️ Target Hardware

- **Dell XPS 13 9370** with Intel i5-8250U (Kaby Lake)
- **Intel Graphics**: Hardware acceleration and power management
- **YubiKey**: PIV/FIDO2 authentication and GPG signing
- **TPM 2.0**: Hardware security module support

## 📦 Installation

1. **Clone Configuration**:
   ```bash
   git clone https://github.com/heytcass/nixos-config.git ~/.nixos
   cd ~/.nixos
   ```

2. **Update Hardware Configuration**:
   ```bash
   # Generate for your hardware
   nixos-generate-config --show-hardware-config > hardware-configuration.nix
   ```

3. **Customize Personal Settings**:
   - Update user info in `modules/options.nix` (name, email, etc.)
   - Update hostname and system-specific settings
   - Review flake inputs for custom packages

4. **Build and Deploy**:
   ```bash
   # Test build first
   sudo nixos-rebuild build --flake .#gti
   
   # Deploy system
   sudo nixos-rebuild switch --flake .#gti
   ```

## 🔐 Secrets Management

This configuration uses **sops-nix** for encrypted secrets:

- **Encrypted Files**: `secrets/*.yaml` contain AES256-GCM encrypted values
- **Age Keys**: Managed automatically, never commit plaintext secrets
- **Categories**: Organized into business, development, and system secrets

To set up secrets:
```bash
# Generate age key
age-keygen -o ~/.config/sops/age/keys.txt

# Edit secrets (will use your age key)
sops secrets/secrets.yaml
```

## 🛡️ Secure Boot (Optional)

Enable hardware-verified boot chain:

1. **Generate Keys**:
   ```bash
   sudo sbctl create-keys
   sudo sbctl enroll-keys --microsoft
   ```

2. **Enable Lanzaboote**:
   ```bash
   # Edit modules/secure-boot.nix
   # Set: boot.lanzaboote.enable = true;
   sudo nixos-rebuild switch --flake .#gti
   ```

3. **Enable in UEFI**: Boot to UEFI settings and enable Secure Boot

## 🔧 Key Commands

```bash
# System management
rebuild        # Rebuild and switch system
fastbuild      # Use nix-fast-build for parallel builds

# Remote deployment
deploy-remote  # Deploy to remote systems with nixos-anywhere

# System analysis
nix-why        # Visualize dependency tree
nix-compare    # Compare system generations
nix-size       # Analyze disk usage

# Development
nix develop    # Enter development shell
```

## 📁 Structure

```
├── modules/
│   ├── options.nix      # Typed system options (replaces shared.nix)
│   ├── boot.nix         # Boot, kernel, sysctls
│   ├── hardware.nix     # Hardware-specific optimizations
│   ├── desktop.nix      # GNOME desktop environment
│   ├── security.nix     # Security hardening, YubiKey
│   ├── networking.nix   # Network configuration
│   ├── tools.nix        # CLI tools and shell configuration
│   ├── secrets.nix      # Encrypted secrets management
│   ├── secure-boot.nix  # Secure boot and TPM2 support
│   └── advanced-tools.nix # Modern NixOS ecosystem tools
├── secrets/
│   ├── secrets.yaml     # Encrypted system secrets
│   └── user-secrets.yaml # Encrypted user secrets
├── configuration.nix    # Main system configuration
├── home.nix           # Home-manager user configuration
├── flake.nix          # Flake inputs and outputs
└── PRD.md             # Complete implementation roadmap
```

## 🔄 Next Steps

After deployment, complete these manual configurations:

1. **YubiKey Setup**: Register for FIDO2/U2F authentication
2. **Secrets Activation**: Configure age keys and re-enable encrypted secrets
3. **GNOME Extensions**: Install additional extensions via Extensions Manager
4. **Professional Audio**: Configure EasyEffects presets for video calls

See `PRD.md` for detailed implementation status and next steps.

## 📋 System Status

- ✅ **Phase 1**: Security hardening and structured secrets
- ✅ **Phase 2**: Professional communication and productivity
- ✅ **Phase 3**: Architecture migration to typed options
- ✅ **Phase 4**: Advanced NixOS ecosystem tools

All phases completed successfully with zero breaking changes!

## 🤝 Contributing

This is a personal configuration, but feel free to:
- Use modules or patterns for your own setup
- Report issues or suggest improvements
- Adapt the architecture for your use case

## 📄 License

MIT License - see the configuration and adapt as needed for your systems.