# Productivity applications profile
# Heavy desktop applications for productivity and professional work

{
  pkgs,
  lib,
  isWorkstation,
  isISO,
  ...
}:

{
  # Productivity applications (conditionally loaded for workstations and laptops)
  environment.systemPackages = lib.optionals (!isISO) (with pkgs; [
    # Web browsers (only what was actually in original config)
    google-chrome
    
    # Security and password management
    bitwarden-desktop
    
    # Development tools
    vscode
    
    # Claude AI assistant
    claude-code
  ]);
}