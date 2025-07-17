# Development Environment Templates

This directory contains optimized development environment templates that provide project-specific toolchains without bloating the system configuration.

## 🎯 **Philosophy**

Instead of installing heavy development tools system-wide, these templates provide:
- **Project-specific environments** - Only load tools when needed
- **Reproducible setups** - Consistent toolchains across projects
- **Storage efficiency** - Avoid duplicate installations
- **Easy switching** - Switch between different language environments

## 🛠️ **Available Templates**

### Rust Development (`rust-dev/`)
- **Rust toolchain**: Latest stable with rust-analyzer
- **Cargo tools**: cargo-watch, cargo-nextest, cargo-audit, cargo-edit
- **Build dependencies**: pkg-config, openssl
- **Usage**: `dev-env rust` or `nix develop` in project with rust template

### Web Development (`web-dev/`)
- **Node.js**: Version 20 with npm, yarn, pnpm
- **TypeScript**: Full TypeScript support
- **Linting**: ESLint, Prettier
- **Build tools**: Vite, Webpack
- **Usage**: `dev-env web` or `nix develop` in project with web template

### Python Development (`python-dev/`)
- **Python**: Version 3.11 with pip, venv
- **Code quality**: Black, flake8, mypy
- **Testing**: pytest
- **Usage**: `dev-env python` or `nix develop` in project with python template

## 🚀 **Usage**

### Quick Start
```bash
# Enter a development environment
dev-env rust           # Enter Rust development shell
dev-env web            # Enter web development shell
dev-env python         # Enter Python development shell

# Initialize a project with a specific environment
dev-env rust init      # Copy flake.nix to current directory
dev-env web init       # Copy flake.nix to current directory

# Run commands in an environment
dev-env rust run cargo --version
dev-env web run npm --version
```

### Project-Specific Setup
```bash
# In your project directory
dev-env rust init      # Creates flake.nix with Rust environment
nix develop            # Enter the environment
```

### On-Demand Tools
For tools you need occasionally, use `nix run`:
```bash
# Container management
lazydocker             # Alias for: nix run nixpkgs#lazydocker

# Security tools
yubikey-manager        # Alias for: nix run nixpkgs#yubikey-manager

# Quick language checks
nodejs --version       # Alias for: nix run nixpkgs#nodejs -- --version
rustc --version        # Alias for: nix run nixpkgs#rustc -- --version
python --version       # Alias for: nix run nixpkgs#python3 -- --version
```

## 📦 **Storage Benefits**

This approach provides significant storage savings:
- **Before**: ~1.5GB+ of development tools always installed
- **After**: ~100MB of essential tools + on-demand loading
- **Savings**: ~1.4GB+ freed up, faster system builds

### What's No Longer System-Wide
- **Rust compiler** (800MB+) - Use `dev-env rust` instead
- **Node.js/npm** (200MB+) - Use `dev-env web` instead
- **Python packages** (100MB+) - Use `dev-env python` instead
- **Heavy development tools** - Use `nix run` for occasional use

## 🔧 **Customization**

### Adding New Languages
1. Create a new template directory (e.g., `go-dev/`)
2. Add a `flake.nix` with the language toolchain
3. Update the `dev-env.sh` script to include the new environment

### Modifying Existing Templates
Edit the `flake.nix` files to add/remove tools as needed. The templates are designed to be starting points that you can customize per project.

## 🎨 **Integration**

The development environment system integrates seamlessly with:
- **VS Code/Claude Code** - Automatic environment detection
- **Shell integration** - Aliases available in fish/bash
- **Git workflows** - Each project can have its own toolchain
- **CI/CD** - Reproducible builds with locked dependencies

## 🔒 **Security**

All development tools are:
- **Sandboxed** - Run in isolated Nix environments
- **Reproducible** - Locked to specific versions
- **Verified** - Downloaded from trusted binary caches
- **Minimal** - Only include necessary tools per project