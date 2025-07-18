# Base NixOS configuration
# This file is imported by all NixOS systems and provides the foundation

{
  lib,
  desktop,
  isWorkstation,
  isISO,
  ...
}:

{
  imports =
    [
      # Import base system configuration
      ./_mixins/services/base.nix

      # Import Stylix theming
      ./_mixins/services/stylix.nix

      # Import Matugen Material You color generation
      ./_mixins/services/matugen.nix

      # Import development tools for all systems
      ./_mixins/features/development.nix

      # Import user configuration
      ./_mixins/services/users.nix

      # Import Tailscale networking
      ./_mixins/services/tailscale.nix

      # Import Claude MCP server configuration
      ./_mixins/services/claude-mcp.nix
    ]
    ++ lib.optionals (!isISO) [
      # Import Jasper personal AI assistant (only for non-ISO systems)
      ./_mixins/services/jasper.nix
    ]
    ++ lib.optionals (!isISO) [
      # Import secrets management (only for non-ISO systems)
      ./_mixins/services/secrets.nix
    ]
    ++ lib.optionals (!isISO && desktop == "gnome") [
      # Import GNOME desktop configuration
      ./_mixins/desktop/gnome.nix
    ]
    ++ lib.optionals (!isISO && desktop == "hyprland") [
      # Import Hyprland desktop configuration
      ./_mixins/desktop/hyprland.nix
    ]
    ++ lib.optionals (!isISO && desktop == "niri") [
      # Import Niri desktop configuration
      ./_mixins/desktop/niri.nix
    ]
    ++ lib.optionals (!isISO) [
      # Import Rust utilities for non-ISO systems
      ./_mixins/features/rust-utils.nix
    ]
    ++ lib.optionals isWorkstation [
      # Import gaming features only for workstations
      ./_mixins/features/gaming.nix
    ];

  # System state version - consistent across all hosts (but let ISO override)
  system.stateVersion = lib.mkIf (!isISO) "25.05";
}
