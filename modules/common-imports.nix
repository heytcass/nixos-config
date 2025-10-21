# Common module imports shared across all systems
# This eliminates duplication in system configurations

{ claude-desktop-linux-flake, sops-nix, nix-output-monitor, ... }:

[
  ./base.nix
  ./options.nix
  ./boot.nix
  ./hardware.nix
  ./desktop.nix
  ./networking.nix
  ./security.nix
  ./performance.nix
  ./systemd.nix
  { _module.args = { inherit claude-desktop-linux-flake sops-nix nix-output-monitor; }; }
  ./tools.nix
  ./secrets.nix
  ./advanced-tools.nix
  ./oomd.nix
]
