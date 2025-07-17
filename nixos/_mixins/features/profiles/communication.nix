# Communication applications profile
# Heavy desktop applications for communication and collaboration

{
  pkgs,
  lib,
  isWorkstation,
  ...
}:

{
  # Communication applications (conditionally loaded for workstations)
  environment.systemPackages = lib.optionals isWorkstation (with pkgs; [
    # Communication platforms
    discord
    slack
    zoom-us
    teams-for-linux
    
    # Email and calendar
    thunderbird
    
    # Matrix client
    element-desktop
  ]);
}