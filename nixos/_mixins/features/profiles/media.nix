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
  environment.systemPackages = lib.optionals isWorkstation (with pkgs; [
    # Media consumption
    spotify
    vlc
    
    # Media creation
    obs-studio
    audacity
    
    # Image editing
    gimp
    inkscape
    
    # Video editing
    kdenlive
  ]);
}