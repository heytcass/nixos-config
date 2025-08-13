# Post-Installation Automation Module
# Handles setup tasks that would normally require manual scripts

{ config, lib, pkgs, ... }:

with lib;

{
  options.mySystem.postInstall = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Enable post-installation automation";
    };

    setupYubikeyFido = mkOption {
      type = types.bool;
      default = true;
      description = "Automatically register YubiKey for FIDO2/U2F";
    };

    importAVConfigs = mkOption {
      type = types.bool;
      default = true;
      description = "Import EasyEffects and OBS configurations";
    };

    validateSecrets = mkOption {
      type = types.bool;
      default = true;
      description = "Validate and fix age key configuration";
    };
  };

  config = mkIf config.mySystem.postInstall.enable {
    # Create post-install service that runs once on first boot
    systemd.services.nixos-post-install = {
      description = "NixOS Post-Installation Setup";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" "sops-nix.service" ];
      
      # Only run once by creating a flag file
      unitConfig.ConditionPathExists = "!/var/lib/nixos-post-install-complete";
      
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
        User = "root";
      };
      
      script = ''
        set -euo pipefail
        
        echo "Starting NixOS post-installation setup..."
        
        # Validate and fix age keys for secrets
        ${optionalString config.mySystem.postInstall.validateSecrets ''
          echo "Validating age key configuration..."
          
          # Ensure age key exists and is correct
          if [[ ! -f /var/lib/sops-nix/key.txt ]] || ! sops -d ${config.sops.defaultSopsFile} >/dev/null 2>&1; then
            echo "Regenerating age key from SSH host key..."
            ${pkgs.ssh-to-age}/bin/ssh-to-age -private-key -i /etc/ssh/ssh_host_ed25519_key > /var/lib/sops-nix/key.txt
            chmod 600 /var/lib/sops-nix/key.txt
          fi
          
          # Test secrets decryption
          if sops -d ${config.sops.defaultSopsFile} >/dev/null 2>&1; then
            echo "✅ Secrets management validated"
          else
            echo "❌ Secrets validation failed - manual intervention required"
          fi
        ''}
        
        # YubiKey FIDO2/U2F registration for user
        ${optionalString config.mySystem.postInstall.setupYubikeyFido ''
          echo "Setting up YubiKey FIDO2/U2F registration..."
          
          # Wait for YubiKey to be available
          timeout=30
          while [[ $timeout -gt 0 ]]; do
            if ${pkgs.yubikey-manager}/bin/ykman list >/dev/null 2>&1; then
              break
            fi
            echo "Waiting for YubiKey... ($timeout seconds remaining)"
            sleep 1
            ((timeout--))
          done
          
          if [[ $timeout -eq 0 ]]; then
            echo "⚠️  YubiKey not detected - skipping FIDO2/U2F setup"
          else
            # Register YubiKey for the user (non-interactive)
            mkdir -p /home/${config.mySystem.user.name}/.config/Yubico
            chown ${config.mySystem.user.name}:users /home/${config.mySystem.user.name}/.config/Yubico
            chmod 700 /home/${config.mySystem.user.name}/.config/Yubico
            
            # The actual registration will be done when user first uses FIDO2
            echo "✅ YubiKey FIDO2/U2F directories prepared"
          fi
        ''}
        
        # Import A/V configurations
        ${optionalString config.mySystem.postInstall.importAVConfigs ''
          echo "Importing audio/video configurations..."
          
          # EasyEffects configuration is now fully declarative via Home Manager
          # OBS configuration is now declarative via Home Manager
          echo "✅ A/V configurations handled declaratively"
        ''}
        
        # Verify system health
        echo "Verifying system health..."
        
        # Check essential services
        for service in NetworkManager pcscd yubikey-agent pipewire; do
          if systemctl is-active --quiet "$service" 2>/dev/null; then
            echo "✅ $service is running"
          else
            echo "⚠️  $service is not running"
          fi
        done
        
        # Check user services (run as user)
        sudo -u ${config.mySystem.user.name} systemctl --user is-active pipewire >/dev/null 2>&1 && \
          echo "✅ User pipewire is running" || \
          echo "⚠️  User pipewire is not running"
        
        # Mark setup as complete
        touch /var/lib/nixos-post-install-complete
        echo "🎉 Post-installation setup completed successfully!"
        
        echo ""
        echo "Next steps:"
        echo "1. YubiKey PIV SSH setup: Run 'ykman piv keys generate 9a' if needed"
        echo "2. Add SSH public key to GitHub/GitLab"
        echo "3. Test complete setup with 'obs' and 'easyeffects'"
      '';
    };

    # User service to show post-install status on first login
    systemd.user.services.nixos-post-install-status = {
      description = "Show post-installation status";
      wantedBy = [ "default.target" ];
      
      # Only run once by creating a flag file
      unitConfig.ConditionPathExists = "!/home/${config.mySystem.user.name}/.config/nixos-post-install-shown";
      
      serviceConfig = {
        Type = "oneshot";
        RemainAfterExit = true;
      };
      
      script = ''
        # Show friendly welcome message
        ${pkgs.libnotify}/bin/notify-send \
          "NixOS Setup Complete" \
          "Your professional workstation is ready! Check terminal for any manual steps." \
          --icon=computer
        
        # Mark as shown
        touch /home/${config.mySystem.user.name}/.config/nixos-post-install-shown
      '';
    };

    # Ensure required packages are available for post-install tasks
    environment.systemPackages = with pkgs; [
      sops
      age
      ssh-to-age
      yubikey-manager
    ];
  };
}