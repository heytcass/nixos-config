{ config, pkgs, lib, ... }:

let
  shared = import ./shared.nix { inherit lib pkgs; };
  
  # Network security parameters
  networkSecurity = {
    "net.ipv4.conf.default.rp_filter" = 1;
    "net.ipv4.conf.all.rp_filter" = 1;
    "net.ipv4.conf.default.log_martians" = 1;
    "net.ipv4.conf.all.log_martians" = 1;
    "net.ipv4.conf.all.accept_redirects" = 0;
    "net.ipv4.conf.default.accept_redirects" = 0;
    "net.ipv6.conf.all.accept_redirects" = 0;
    "net.ipv6.conf.default.accept_redirects" = 0;
    "net.ipv4.conf.all.secure_redirects" = 0;
    "net.ipv4.conf.default.secure_redirects" = 0;
    "net.ipv4.conf.all.accept_source_route" = 0;
    "net.ipv4.conf.default.accept_source_route" = 0;
    "net.ipv6.conf.all.accept_source_route" = 0;
    "net.ipv6.conf.default.accept_source_route" = 0;
  };
  
  # Kernel hardening parameters
  kernelSecurity = {
    "kernel.dmesg_restrict" = 1;
    "kernel.kptr_restrict" = 2;
    "kernel.yama.ptrace_scope" = 1;
  };
in
{
  security = {
    # Essential security services
    rtkit.enable = true;
    protectKernelImage = true;
    
    # Privilege escalation configuration
    sudo = {
      enable = true;
      execWheelOnly = true;
      extraConfig = "Defaults timestamp_timeout=30";
    };
    
    # Mandatory access control
    apparmor = {
      enable = true;
      killUnconfinedConfinables = true;
    };
    
    # Security monitoring
    auditd.enable = true;
  };

  # Security monitoring services
  services = {
    # Intrusion prevention
    fail2ban = {
      enable = true;
      maxretry = 3;
      bantime = "1h";
      ignoreIP = [
        "127.0.0.0/8"
        "10.0.0.0/8"
        "192.168.0.0/16"
        "172.16.0.0/12"
      ];
    };
    
    # Smart card daemon for YubiKey
    pcscd = {
      enable = true;
      plugins = [ pkgs.ccid ];
    };
    
    # Enhanced YubiKey support
    yubikey-agent.enable = true;  # SSH agent integration
  };

  # Enhanced YubiKey udev rules and FIDO2 support
  services.udev.packages = with pkgs; [ 
    yubikey-personalization 
    libu2f-host  # FIDO2/U2F support
  ];
  
  # FIDO2 authentication support
  security.pam.u2f = {
    enable = true;
    settings.cue = true;  # Show touch notification
  };

  # Kernel security hardening
  boot.kernel.sysctl = networkSecurity // kernelSecurity;

  # Manual system management preferred
  system.autoUpgrade.enable = false;
}