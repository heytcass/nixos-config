{ config, pkgs, ... }:

{
  # VS Code and extensions
  environment.systemPackages = with pkgs; [
    (vscode-with-extensions.override {
      vscodeExtensions = with vscode-extensions; [
        # Base functionality
        bbenoist.nix              # Nix support
        mkhl.direnv              # direnv integration
        
        # Essential features
        vscodevim.vim            # Vim keybindings
        editorconfig.editorconfig # EditorConfig support

        # Formatting
        esbenp.prettier-vscode    # Prettier code formatter

        # Language support
        redhat.vscode-yaml        # YAML support
      ];
    })
  ];

  # Enable Wayland support for VS Code
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  # Needed for VS Code to store authentication tokens
  services.gnome.gnome-keyring.enable = true;
}
