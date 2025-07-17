{
  description = "Python development environment";

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
            # Python environment
            python311
            python311Packages.pip
            python311Packages.venv
            
            # Development tools
            python311Packages.black
            python311Packages.flake8
            python311Packages.pytest
            python311Packages.mypy
            
            # Optional: Common packages
            # python311Packages.requests
            # python311Packages.flask
            # python311Packages.django
          ];

          shellHook = ''
            echo "🐍 Python development environment"
            echo "   Python version: $(python --version)"
            echo "   pip version: $(pip --version)"
            
            # Create virtual environment if it doesn't exist
            if [ ! -d venv ]; then
              echo "   Creating virtual environment..."
              python -m venv venv
            fi
            
            echo "   Activate with: source venv/bin/activate"
          '';
        };
      });
}