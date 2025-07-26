{
  description = "Rust development environment";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    rust-overlay.url = "github:oxalica/rust-overlay";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs =
    {
      nixpkgs,
      rust-overlay,
      flake-utils,
    }:
    flake-utils.lib.eachDefaultSystem (
      system:
      let
        overlays = [ (import rust-overlay) ];
        pkgs = import nixpkgs {
          inherit system overlays;
        };
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            # Rust toolchain
            rust-bin.stable.latest.default
            rust-analyzer

            # Development tools
            cargo-watch
            cargo-nextest
            cargo-audit
            cargo-edit

            # Build dependencies
            pkg-config
            openssl

            # Optional: Additional tools
            # cargo-flamegraph
            # cargo-benchcmp
          ];

          shellHook = ''
            echo "🦀 Rust development environment"
            echo "   Rust version: $(rustc --version)"
            echo "   Cargo version: $(cargo --version)"
          '';
        };
      }
    );
}
