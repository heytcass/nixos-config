# NixOS Configuration Helper

## Common Commands
- Build and switch to new configuration: `sudo nixos-rebuild switch --flake ~/.nixos-config#gti`
- Build but don't activate: `sudo nixos-rebuild build --flake ~/.nixos-config#gti`
- Test configuration: `sudo nixos-rebuild test --flake ~/.nixos-config#gti`
- Check configuration for errors: `nix flake check`
- Update flake inputs: `nix flake update`

## Style Guidelines
- **Formatting**: 2-space indentation, 80-character line limit where practical
- **Naming**: Use descriptive camelCase for variables and function arguments
- **Organization**: Group related configurations together with clear comments
- **Imports**: Place imports at the top of files, with descriptive comments
- **Error Handling**: Use `lib.mkIf` for conditional configurations
- **Comments**: Add comments for non-obvious configurations and options

## Repository Structure
- `flake.nix`: Main entry point, defines inputs and outputs
- `configuration.nix`: System-wide NixOS configuration
- `home.nix`: User-specific configuration via Home Manager
- `hardware-configuration.nix`: Hardware-specific settings (don't edit manually)