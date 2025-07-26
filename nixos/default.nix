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
  imports = [
    # Import base system configuration
    ./_mixins/services/base.nix

    # Import Stylix theming
    ./_mixins/services/stylix.nix

    # Import development tools for all systems
    ./_mixins/features/development.nix

    # Import user configuration
    ./_mixins/services/users.nix

    # Import network services (SSH, NetworkManager)
    ./_mixins/services/networking.nix

    # Import Tailscale VPN
    ./_mixins/services/tailscale.nix

    # Import Claude MCP server configuration
    ./_mixins/services/claude-mcp.nix

    # Import source cleanup service
    ./_mixins/services/source-cleanup.nix

    # Import dock detection service
    ./_mixins/services/dock-detection.nix
  ]
  ++ lib.optionals (!isISO) [
    # Import non-ISO system features and services
    ./_mixins/services/jasper.nix
    ./_mixins/services/secrets.nix
    ./_mixins/features/rust-utils.nix
    ./_mixins/features/profiles/productivity.nix
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
  ++ lib.optionals isWorkstation [
    # Import gaming features only for workstations
    ./_mixins/features/gaming.nix
    # Import communication and media profiles for workstations
    ./_mixins/features/profiles/communication.nix
    ./_mixins/features/profiles/media.nix
  ];

  # System state version - consistent across all hosts (but let ISO override)
  system.stateVersion = lib.mkIf (!isISO) "25.05";
}
