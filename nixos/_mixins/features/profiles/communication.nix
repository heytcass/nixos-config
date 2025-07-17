# Communication applications profile
# Heavy desktop applications for communication and collaboration

{
  pkgs,
  lib,
  isWorkstation,
  isISO,
  ...
}:

{
  # Communication applications (conditionally loaded for workstations)
  environment.systemPackages = lib.optionals isWorkstation (with pkgs; [
    # Communication platforms (only what was actually in original config)
    discord
    slack
    zoom-us
    teams-for-linux  # This was in gnome.nix
  ]);
}