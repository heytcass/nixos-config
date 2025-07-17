# Productivity applications profile
# Heavy desktop applications for productivity and professional work

{
  pkgs,
  lib,
  isWorkstation,
  ...
}:

{
  # Productivity applications (conditionally loaded for workstations)
  environment.systemPackages = lib.optionals isWorkstation (with pkgs; [
    # Web browsers
    google-chrome
    firefox
    
    # Security and password management
    bitwarden-desktop
    
    # Office suite
    libreoffice
    
    # PDF viewer and editor
    zathura
    evince
    
    # Note-taking
    obsidian
    
    # Development tools
    vscode
    
    # Claude AI assistant
    claude-code
  ]);
}