# Source cleanup service for large cached sources
# Targets the massive source caches that build up over time

{
  lib,
  pkgs,
  isISO,
  ...
}:

{
  # Source cleanup systemd service
  systemd.services.nix-source-cleanup = lib.mkIf (!isISO) {
    description = "Clean up large Nix source caches";
    serviceConfig = {
      Type = "oneshot";
      User = "root";
      ExecStart = pkgs.writeShellScript "source-cleanup" ''
        set -e

        echo "🧹 Starting Nix source cleanup..."

        # Find and remove large source directories older than 7 days
        find /nix/store -maxdepth 1 -name "*-source" -type d -mtime +7 -exec du -sh {} \; | \
          sort -hr | head -20 | while read size path; do
            if [[ $size =~ ^[0-9]+(\.[0-9]+)?G ]]; then
              echo "🗑️  Removing large source cache: $path ($size)"
              rm -rf "$path" || true
            fi
          done

        # Clean up build-time dependencies that aren't runtime dependencies
        nix-collect-garbage --delete-older-than 7d

        # Optimize store after cleanup
        nix-store --optimize

        echo "✅ Source cleanup complete"
      '';
      TimeoutSec = 3600; # 1 hour timeout
    };
    unitConfig = {
      ConditionPathExists = "/nix/store";
    };
  };

  # Systemd timer for bi-weekly source cleanup
  systemd.timers.nix-source-cleanup = lib.mkIf (!isISO) {
    description = "Bi-weekly Nix source cleanup";
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "bi-weekly";
      Persistent = true;
      RandomizedDelaySec = "2h";
    };
  };
}
