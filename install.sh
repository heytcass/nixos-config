#!/usr/bin/env bash
# NixOS Installation Script for Tom's Configuration

set -e

# Display usage information
show_usage() {
  echo "Usage: $0 [options] hostname disk"
  echo
  echo "Arguments:"
  echo "  hostname    Either 'gti' or 'transporter'"
  echo "  disk        Target disk (e.g., /dev/nvme0n1)"
  echo
  echo "Options:"
  echo "  -h, --help  Show this help message"
  echo "  -d, --dry-run  Show what would be done without making changes"
  echo 
  echo "Example:"
  echo "  $0 transporter /dev/sda"
  exit 1
}

# Parse command line options
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case $1 in
    -h|--help)
      show_usage
      ;;
    -d|--dry-run)
      DRY_RUN=1
      shift
      ;;
    *)
      if [[ -z "$HOSTNAME" ]]; then
        HOSTNAME="$1"
      elif [[ -z "$DISK" ]]; then
        DISK="$1"
      else
        echo "Error: Unknown parameter: $1"
        show_usage
      fi
      shift
      ;;
  esac
done

# Validate arguments
if [[ -z "$HOSTNAME" || -z "$DISK" ]]; then
  echo "Error: Missing required arguments."
  show_usage
fi

if [[ "$HOSTNAME" != "gti" && "$HOSTNAME" != "transporter" ]]; then
  echo "Error: Hostname must be either 'gti' or 'transporter'"
  exit 1
fi

if [[ ! -e "$DISK" ]]; then
  echo "Error: Disk '$DISK' does not exist."
  exit 1
fi

echo "============================================================="
echo " NixOS Installation: $HOSTNAME on $DISK"
echo "============================================================="

# Safety confirmation
if [[ $DRY_RUN -eq 0 ]]; then
  echo
  echo "WARNING: This will ERASE ALL DATA on $DISK and install NixOS."
  echo "This operation cannot be undone!"
  echo
  read -p "Are you sure you want to continue? (yes/no): " CONFIRM
  
  if [[ "$CONFIRM" != "yes" ]]; then
    echo "Installation aborted."
    exit 1
  fi
fi

# Function to execute or simulate commands
run_cmd() {
  if [[ $DRY_RUN -eq 1 ]]; then
    echo "WOULD RUN: $@"
  else
    echo "RUNNING: $@"
    eval "$@"
  fi
}

echo "Creating partitions on $DISK..."
run_cmd "parted $DISK -- mklabel gpt"
run_cmd "parted $DISK -- mkpart ESP fat32 1MiB 512MiB"
run_cmd "parted $DISK -- set 1 boot on"
run_cmd "parted $DISK -- mkpart primary 512MiB 100%"

# Determine partition names based on device name
if [[ "$DISK" == *"nvme"* ]]; then
  BOOT_PART="${DISK}p1"
  ROOT_PART="${DISK}p2"
else
  BOOT_PART="${DISK}1"
  ROOT_PART="${DISK}2"
fi

echo "Formatting partitions..."
run_cmd "mkfs.fat -F 32 -n boot $BOOT_PART"
run_cmd "mkfs.ext4 -L nixos $ROOT_PART"

echo "Mounting partitions..."
run_cmd "mount $ROOT_PART /mnt"
run_cmd "mkdir -p /mnt/boot"
run_cmd "mount $BOOT_PART /mnt/boot"

echo "Generating hardware configuration..."
run_cmd "nixos-generate-config --root /mnt"

echo "Copying hardware configuration..."
run_cmd "mkdir -p /mnt/home/tom/.nixos-config/hosts/$HOSTNAME"
run_cmd "cp /mnt/etc/nixos/hardware-configuration.nix /mnt/home/tom/.nixos-config/hosts/$HOSTNAME/hardware.nix"

if [[ -d "/home/tom/.nixos-config" ]]; then
  echo "Copying existing configuration..."
  run_cmd "cp -r /home/tom/.nixos-config/* /mnt/home/tom/.nixos-config/"
else
  echo "Cloning configuration from Git..."
  run_cmd "git clone https://github.com/yourusername/nixos-config /mnt/home/tom/.nixos-config"
fi

echo "Installing NixOS for $HOSTNAME..."
if [[ $DRY_RUN -eq 0 ]]; then
  nixos-install --flake /mnt/home/tom/.nixos-config#$HOSTNAME
  
  echo "Installation complete!"
  echo
  echo "You can now reboot into your new system."
  echo "After rebooting, log in as root and set a password for your user:"
  echo "# passwd tom"
else
  echo "WOULD RUN: nixos-install --flake /mnt/home/tom/.nixos-config#$HOSTNAME"
  echo "Dry run completed. No changes were made."
fi