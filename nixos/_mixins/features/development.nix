# Development tools and environment mixin
# Provides essential development tools and configurations

{
  pkgs,
  inputs,
  ...
}:

{

  # Essential development packages (always loaded)
  environment.systemPackages = with pkgs; [
    # Claude Desktop with FHS for MCP servers
    inputs.claude-desktop.packages.${pkgs.system}.claude-desktop-with-fhs

    # Essential development tools
    git
    curl
    wget
    micro
    marker
    
    # Terminal multiplexing and session management
    zellij           # Modern terminal multiplexer (preferred over tmux)
    
    # Modern Git workflow tools
    lazygit          # Most popular, intuitive Git TUI
    gitui            # Rust-based Git TUI alternative
    delta            # Better diff viewer with syntax highlighting
    git-absorb       # Automatic fixup commits
    git-cliff        # Changelog generation
    
    # Code navigation and search
    ripgrep          # Fast search (rg)
    fzf              # Fuzzy finder for files/commands
    zoxide           # Smart directory navigation (z command)
    fd               # Fast find alternative
    just             # Command runner (modern make alternative)
    
    # Language servers and development tools
    nil              # Nix LSP
    nixd             # Alternative Nix LSP  
    nixfmt-rfc-style # Nix formatting
    
    # Container development
    skopeo           # Container image operations
    buildah          # Container building
    
    # Binary cache tools
    cachix
    
    # Container tools (lightweight)
    podman
    
    # Development environment manager
    (writeShellScriptBin "dev-env" ''
      #!/usr/bin/env bash
      
      # Development environment activation script
      # Provides easy access to project-specific development environments
      
      set -e
      
      TEMPLATES_DIR="/home/tom/.nixos/templates"
      
      show_help() {
          echo "🔧 Development Environment Manager"
          echo
          echo "Usage: $0 <environment> [action]"
          echo
          echo "Available environments:"
          echo "  rust      - Rust development with latest stable toolchain"
          echo "  web       - Web development with Node.js, npm, TypeScript"
          echo "  python    - Python development with pip, venv, testing tools"
          echo
          echo "Actions:"
          echo "  init      - Initialize environment in current directory"
          echo "  shell     - Enter development shell (default)"
          echo "  run       - Run a command in the environment"
          echo
          echo "Examples:"
          echo "  $0 rust           # Enter Rust development shell"
          echo "  $0 web init       # Initialize web dev environment"
          echo "  $0 python run python --version"
          echo
          echo "On-demand tools (no installation needed):"
          echo "  nix run nixpkgs#lazydocker"
          echo "  nix run nixpkgs#yubikey-manager"
          echo "  nix run nixpkgs#rustc -- --version"
          echo "  nix run nixpkgs#nodejs -- --version"
      }
      
      init_environment() {
          local env_type="$1"
          local template_dir="$TEMPLATES_DIR/$env_type-dev"
          
          if [ ! -d "$template_dir" ]; then
              echo "❌ Environment template '$env_type' not found"
              echo "Available templates:"
              ls "$TEMPLATES_DIR" | grep -E '.*-dev$' | sed 's/-dev$//' | sed 's/^/  /'
              exit 1
          fi
          
          if [ -f "flake.nix" ]; then
              echo "⚠️  flake.nix already exists. Overwrite? (y/N)"
              read -r response
              if [[ ! "$response" =~ ^[Yy]$ ]]; then
                  echo "Cancelled."
                  exit 1
              fi
          fi
          
          echo "📋 Initializing $env_type development environment..."
          cp "$template_dir/flake.nix" .
          
          echo "✅ Environment initialized!"
          echo "   Run 'nix develop' to enter the development shell"
      }
      
      enter_shell() {
          local env_type="$1"
          local template_dir="$TEMPLATES_DIR/$env_type-dev"
          
          if [ ! -d "$template_dir" ]; then
              echo "❌ Environment template '$env_type' not found"
              exit 1
          fi
          
          echo "🚀 Entering $env_type development environment..."
          cd "$template_dir"
          nix develop
      }
      
      run_command() {
          local env_type="$1"
          shift
          local template_dir="$TEMPLATES_DIR/$env_type-dev"
          
          if [ ! -d "$template_dir" ]; then
              echo "❌ Environment template '$env_type' not found"
              exit 1
          fi
          
          echo "🏃 Running command in $env_type environment..."
          cd "$template_dir"
          nix develop --command "$@"
      }
      
      # Main script logic
      if [ $# -eq 0 ]; then
          show_help
          exit 0
      fi
      
      case "$1" in
          -h|--help|help)
              show_help
              ;;
          rust|web|python)
              env_type="$1"
              action="''${2:-shell}"
              
              case "$action" in
                  init)
                      init_environment "$env_type"
                      ;;
                  shell)
                      enter_shell "$env_type"
                      ;;
                  run)
                      shift 2
                      run_command "$env_type" "$@"
                      ;;
                  *)
                      echo "❌ Unknown action: $action"
                      show_help
                      exit 1
                      ;;
              esac
              ;;
          *)
              echo "❌ Unknown environment: $1"
              show_help
              exit 1
              ;;
      esac
    '')
    
    # NOTE: Heavy development tools moved to conditional loading:
    # - nodejs/npm: Use project-specific flake.nix or dev-env script
    # - lazydocker: Use on-demand with 'nix run nixpkgs#lazydocker'
    # - yubikey-manager: Use on-demand with 'nix run nixpkgs#yubikey-manager'
    # - rustc: Use 'dev-env rust' for Rust development
  ];

  # Podman configuration
  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # Enable podman socket for container management
  systemd.user.services.podman.wantedBy = [ "default.target" ];

  # Environment variables for container tools
  environment.sessionVariables = {
    DOCKER_HOST = "unix:///run/user/1000/podman/podman.sock";
  };

}
