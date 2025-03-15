# Tom's NixOS Configuration

A flake-based NixOS configuration for multiple machines with different desktop environments.

## System Overview

- **gti**: Dell XPS 13-9370 with GNOME desktop environment
- **transporter**: Dell Latitude 7280 with Hyprland window manager (for testing)

## Repository Structure

```
.nixos-config/
├── flake.nix                  # Main entry point for the configuration
├── CLAUDE.md                  # Documentation for Claude AI
├── README.md                  # This file
├── install.sh                 # Installation script for new machines
├── hosts/                     # Host-specific configurations
│   ├── common/                # Shared configuration for all hosts
│   │   ├── default.nix        # Main common config
│   │   ├── users/             # User configurations
│   │   │   └── tom.nix        # Configuration for user "tom"
│   │   └── optional/          # Optional modules
│   │       ├── gnome.nix      # GNOME desktop environment
│   │       └── hyprland.nix   # Hyprland window manager
│   ├── gti/                   # Dell XPS 13-9370 configuration
│   │   ├── default.nix        # Host-specific settings
│   │   └── hardware.nix       # Hardware configuration
│   └── transporter/           # Dell Latitude 7280 configuration
│       ├── default.nix        # Host-specific settings
│       └── hardware.nix       # Hardware configuration
```

## Common Commands

- Update the system: `sudo nixos-rebuild switch --flake ~/.nixos-config#$(hostname)`
- Test a configuration: `sudo nixos-rebuild test --flake ~/.nixos-config#$(hostname)`
- Update all flake inputs: `nix flake update`
- Update a specific input: `nix flake lock --update-input nixpkgs`

## Installation Instructions

### Installing on a New Machine

1. Boot from a NixOS installation ISO
2. Connect to the internet
3. Clone this repository or copy it from a USB drive
4. Run the installation script:

```bash
# Clone the repository
git clone https://github.com/yourusername/nixos-config ~/.nixos-config
cd ~/.nixos-config

# Run the installation script with hostname and disk
./install.sh transporter /dev/sda
```

The script will:
- Partition and format the disk
- Generate hardware configuration for the machine
- Install NixOS with the appropriate configuration
- Set up boot loader and initial configuration

### Creating a Custom Install ISO

Build a custom installation ISO that includes this configuration:

```bash
nix build .#formats.x86_64-linux.install-iso
```

The resulting ISO will be in `./result/iso/`.

## Desktop Environments

### GNOME (Default on gti)

The default desktop environment on `gti` is GNOME, providing a standard desktop experience.

### Hyprland (Testing on transporter)

Hyprland is a tiling Wayland compositor, enabled by default on `transporter` for testing. Important keybindings:

- `Super + Return`: Open terminal
- `Super + Q`: Close window
- `Super + D`: Open application launcher
- `Super + V`: Toggle floating
- `Super + F`: Toggle fullscreen
- `Super + 1-9`: Switch to workspace
- `Super + Shift + 1-9`: Move window to workspace
- `Print`: Screenshot area to clipboard
- `Shift + Print`: Screenshot area to file

## Adding New Hosts

To add a new host:

1. Create a new directory in `hosts/` with the hostname
2. Create `default.nix` and `hardware.nix` files in the directory
3. Add the host to `flake.nix`
4. If needed, add hardware-specific modules from `nixos-hardware`

## Contributing

Please feel free to submit issues or pull requests to improve the configuration.

## License

This configuration is available under the MIT License.