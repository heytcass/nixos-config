# NixOS Configuration Helper

## System Overview
- **Hardware**: Dell XPS 13-9370 (configured via nixos-hardware)
- **Desktop Environment**: GNOME with Wayland support
- **Terminal**: Ghostty with FiraCode Nerd Font
- **Shell**: Bash with Starship prompt
- **Keyboard Layout**: Colemak
- **Host Name**: gti

## Flakes Best Practices
Always prefer flake-based commands over legacy commands when possible. Flakes provide better reproducibility, dependency management, and version control.

## Repository Structure
- `flake.nix`: Main entry point, defines inputs and outputs (flake-based configuration)
- `configuration.nix`: System-wide NixOS configuration
- `home.nix`: User-specific configuration via Home Manager
- `hardware-configuration.nix`: Hardware-specific settings (don't edit manually)

## Flake Structure
- **Key Inputs**:
  - nixpkgs (stable and unstable channels)
  - home-manager for user environment
  - claude-desktop (AI assistant)
  - nix-vscode-extensions for VS Code setup
  - determinate, flake-utils, impermanence, nixos-generators

## Common Commands
- Build and switch to new configuration: `sudo nixos-rebuild switch --flake ~/.nixos-config#gti`
- Build but don't activate: `sudo nixos-rebuild build --flake ~/.nixos-config#gti`
- Test configuration: `sudo nixos-rebuild test --flake ~/.nixos-config#gti`
- Check configuration for errors: `nix flake check`
- Update all flake inputs: `nix flake update`
- Update specific flake input: `nix flake lock --update-input nixpkgs`
- View flake outputs: `nix flake show`
- Run programs from flakes: `nix run nixpkgs#hello`
- Start development shell from flake: `nix develop`

## Bash Aliases (from home.nix)
- `nrs`: Shorthand for rebuild and switch
- `nrb`: Shorthand for rebuild and build
- `nrt`: Shorthand for rebuild and test
- Modern Unix replacements:
  - `cat` → `bat --paging=never`
  - `ls` → `eza --icons`
  - `ll` → `eza -la --icons`
  - `lt` → `eza --tree --icons`
  - `find` → `fd`
  - `grep` → `rg`
  - `df` → `duf`
  - `top` → `btm`
  - `du` → `duf`

## Core Applications
- **Terminal**: Ghostty (configured in home.nix)
- **Browser**: Google Chrome
- **Text Editor**: VS Code with Nix extensions
- **AI Assistant**: Claude Desktop (with FHS support)
- **Communication**: Slack, Discord
- **Notes**: Obsidian
- **Password Manager**: Bitwarden Desktop
- **Task Management**: Todoist

## Modern Unix Tools
The configuration uses modern replacements for traditional Unix tools:
- `bat` (replaces cat)
- `eza` (replaces ls)
- `fd` (replaces find)
- `ripgrep` (replaces grep)
- `zoxide` (enhances cd)
- `bottom` (replaces top)
- `difftastic` (replaces diff)
- `fzf` (fuzzy finder)
- `lazygit` (git TUI)

## Ghostty Configuration
To configure Ghostty with FiraCode font and Adwaita Dark theme, create a file at `~/.config/ghostty/config` with:
```
# Ghostty terminal configuration

# Font settings
font-family = FiraCode Nerd Font
font-size = 12
font-feature = liga
font-feature = calt
font-feature = ss01
font-feature = ss02
font-feature = ss03
font-feature = ss04
font-feature = ss05

# Window settings
window-padding-x = 10
window-padding-y = 10
window-theme = dark
window-save-state = true
cursor-style = block
cursor-style-blink = true

# Adwaita Dark theme
background = #1d1d1d
foreground = #c0bfbc
selection-background = #3584e4
selection-foreground = #ffffff
cursor-color = #c0bfbc

# Normal colors (Adwaita-like)
palette = 0=#1d1d1d
palette = 1=#ed333b
palette = 2=#57e389
palette = 3=#f8e45c
palette = 4=#3584e4
palette = 5=#c061cb
palette = 6=#5bc8af
palette = 7=#c0bfbc

# Bright colors (Adwaita-like)
palette = 8=#8f8f8f
palette = 9=#f66151
palette = 10=#8ff0a4
palette = 11=#f9f06b
palette = 12=#62a0ea
palette = 13=#dc8add
palette = 14=#93ddc2
palette = 15=#f6f5f4

# UI preferences
confirm-close-surface = false
mouse-hide-while-typing = true
scrollback-lines = 10000
shell-integration-features = no-cursor
```

## Style Guidelines
- **Formatting**: 2-space indentation, 80-character line limit where practical
- **Naming**: Use descriptive camelCase for variables and function arguments
- **Organization**: Group related configurations together with clear comments
- **Imports**: Place imports at the top of files, with descriptive comments
- **Error Handling**: Use `lib.mkIf` for conditional configurations
- **Comments**: Add comments for non-obvious configurations and options
- **Reverting Changes**: Always use Git (`git reset` or `git revert`) to revert changes rather than manual edits

## Flake-Based Development
- When installing new packages, prefer adding them to your flake configuration rather than using `nix-env -i`
- For temporary development environments, use `nix develop` with a flake
- When using tools like `nix-shell`, prefer flake-based alternatives: `nix shell nixpkgs#package`
- To search for packages: `nix search nixpkgs package-name`
- For ad-hoc command execution: `nix run nixpkgs#package -- args`
- When building projects: `nix build .#output` instead of `nix-build`

## Version Control Best Practices
- **Commit Often**: Make small, focused commits with clear messages
- **Test Before Committing**: Always run `nixos-rebuild build` before committing changes
- **Reverting Changes**: 
  - For uncommitted changes: `git restore <file>` or `git reset --hard` (all files)
  - For committed changes: `git revert <commit>` to create a new commit that undoes changes
- **Experimental Changes**: Create a branch with `git checkout -b experiment` for major changes
- **Before Deployment**: Always pull latest changes with `git pull` and resolve any conflicts