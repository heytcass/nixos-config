{ config, lib, pkgs, ... }:

with lib;
{
  options.modules.vscode = {
    enable = mkEnableOption "VSCode configuration";

    extensions = {
      base = mkOption {
        type = types.bool;
        default = true;
        description = "Enable base functionality extensions";
      };

      editing = mkOption {
        type = types.bool;
        default = true;
        description = "Enable editing extensions";
      };

      formatting = mkOption {
        type = types.bool;
        default = true;
        description = "Enable code formatting extensions";
      };

      languages = mkOption {
        type = types.bool;
        default = true;
        description = "Enable language support extensions";
      };
    };

    wayland.enable = mkEnableOption "Wayland support for VSCode";
  };

  config = mkIf config.modules.vscode.enable (mkMerge [
    {
      environment.systemPackages = with pkgs; [
        (vscode-with-extensions.override {
          vscodeExtensions = with vscode-extensions; ([]
            ++ (optionals config.modules.vscode.extensions.base [
              bbenoist.nix     # Nix support
              # mkhl.direnv      # direnv integration
            ])
            ++ (optionals config.modules.vscode.extensions.editing [
              vscodevim.vim           # Vim keybindings
              editorconfig.editorconfig # EditorConfig support
            ])
            ++ (optionals config.modules.vscode.extensions.formatting [
              esbenp.prettier-vscode  # Prettier code formatter
              marp-team.marp-vscode  # Markdown presentation previewer
            ])
            ++ (optionals config.modules.vscode.extensions.languages [
              redhat.vscode-yaml     # YAML support
            ])
          );
        })
      ];

      # Needed for VS Code to store authentication tokens
      services.gnome.gnome-keyring.enable = true;
    }

    (mkIf config.modules.vscode.wayland.enable {
      environment.sessionVariables.NIXOS_OZONE_WL = "1";
    })
  ]);
}