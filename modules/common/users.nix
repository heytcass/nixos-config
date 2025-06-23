{
  pkgs,
  ...
}:
{
  # Base user configuration
  users.users.tom = {
    description = "Tom Cassady";
    extraGroups = [
      "networkmanager"
      "wheel"
      "dialout"
    ];
    isNormalUser = true;
    shell = pkgs.fish;
    packages = with pkgs; [
      # Common applications for both laptops
      apostrophe
      bitwarden-desktop
      boatswain
      claude-code
      discord
      google-chrome
      slack
      spotify
      todoist-electron
      zoom-us
    ];
  };
}
