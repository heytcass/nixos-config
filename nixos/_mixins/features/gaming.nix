# Gaming tools and optimizations mixin
# Provides Steam, GameMode, and gaming-specific optimizations
# Only imported for workstation systems

{
  pkgs,
  ...
}:

{
  # Gaming programs and services
  programs = {
    steam = {
      enable = true;
      gamescopeSession.enable = true;
      remotePlay.openFirewall = true;
      dedicatedServer.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
    };
    gamemode = {
      enable = true;
      enableRenice = true;
    };
  };

  # Additional gaming utilities
  environment.systemPackages = with pkgs; [
    protonup-qt # GUI tool for managing Proton versions
  ];

  # Gaming-specific system tweaks
  boot.kernel.sysctl = {
    "vm.max_map_count" = 2147483642; # Needed for some games
  };
}
