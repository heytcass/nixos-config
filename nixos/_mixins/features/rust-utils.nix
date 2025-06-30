# Rust-based utility replacements mixin
# Provides uutils-coreutils, sudo-rs, and uutils-findutils as modern alternatives

{
  pkgs,
  lib,
  isISO,
  ...
}:

{
  # Install Rust utility packages and configure environment
  environment = {
    systemPackages =
      with pkgs;
      [
        # Memory-safe sudo implementation
        sudo-rs

        # Rust implementations of core utilities (for system availability)
        uutils-coreutils
        uutils-findutils
      ]
      ++ lib.optionals (!isISO) [
        # Additional utilities (skip for ISO to save space)
      ];

    # Ensure both GNU and Rust versions are available in PATH
    pathsToLink = [
      "/bin"
    ];

    # System-wide environment setup
    variables = {
      # Ensure uutils binaries are prioritized in development shells
      UUTILS_PATH = "${pkgs.uutils-coreutils}/bin:${pkgs.uutils-findutils}/bin";
    };
  };

  # Configure sudo-rs as the default sudo implementation
  # This replaces the system sudo while keeping it available as /run/current-system/sw/bin/sudo
  security.sudo.enable = lib.mkForce false;
  security.sudo-rs = {
    enable = true;
    wheelNeedsPassword = true;
  };
}
