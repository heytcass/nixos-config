{
  description = "Web development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Node.js environment
            nodejs_20
            nodePackages.npm
            nodePackages.yarn
            nodePackages.pnpm
            
            # Development tools
            nodePackages.typescript
            nodePackages.eslint
            nodePackages.prettier
            
            # Build tools
            nodePackages.vite
            nodePackages.webpack-cli
            
            # Optional: Additional tools
            # nodePackages.nodemon
            # nodePackages.pm2
          ];

          shellHook = ''
            echo "🌐 Web development environment"
            echo "   Node.js version: $(node --version)"
            echo "   npm version: $(npm --version)"
            
            # Create package.json if it doesn't exist
            if [ ! -f package.json ]; then
              echo "   Run 'npm init' to create a new project"
            fi
          '';
        };
      });
}