# Media applications profile
# Heavy desktop applications for media consumption and creation

{
  pkgs,
  lib,
  isWorkstation,
  ...
}:

{
  # Media applications (conditionally loaded for workstations)
  environment.systemPackages = lib.optionals isWorkstation (
    with pkgs;
    [
      # Media consumption
      spotify

      # Media creation (only packages that were actually in your original config)
      # obs-studio, audacity, gimp, inkscape, kdenlive were not in your original config
    ]
  );
}
