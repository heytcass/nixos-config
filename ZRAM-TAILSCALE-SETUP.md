# ZRAM & Tailscale Setup Guide

This guide covers the newly implemented ZRAM and Tailscale features in your NixOS configuration.

## 🚀 **ZRAM Swap Enhancement**

### What Changed
- **Algorithm**: Upgraded from `lz4` to `zstd` for better compression
- **Priority**: Set to 100 (higher than traditional swap)
- **Memory**: Still uses 50% of RAM for compressed swap

### Benefits
- **Better Performance**: ZRAM swap is much faster than disk-based swap
- **Extended Memory**: Effectively increases available memory through compression
- **SSD Protection**: Reduces wear on your SSDs by avoiding disk swap
- **Laptop Optimized**: Especially beneficial for your Latitude 7280

### How It Works
```bash
# Check ZRAM status after rebuild
sudo swapon --show
# Should show /dev/zram0 with type 'partition' and priority 100

# Monitor ZRAM usage
cat /proc/swaps
# Shows compressed memory usage

# Check compression ratio
sudo zramctl
```

## 🔒 **Tailscale Secure Networking**

### What It Provides
- **Zero-Config VPN**: Secure connection between your laptops
- **Mesh Network**: Direct device-to-device connections
- **Remote Access**: SSH, file sharing, development servers
- **Subnet Routing**: Access to local networks through other devices

### Setup Process

#### 1. **Create Tailscale Account**
1. Go to [tailscale.com](https://tailscale.com) and create a free account
2. This gives you up to 100 devices and 3 users for free

#### 2. **Enable on Both Laptops**
After rebuilding your NixOS configuration:

```bash
# On each laptop, authenticate with Tailscale
sudo tailscale up

# Follow the authentication URL that appears
# This will open your browser to authorize the device
```

#### 3. **Verify Connection**
```bash
# Check Tailscale status
tailscale status

# See your devices and their IP addresses
tailscale ip -4

# Test connectivity between laptops
ping 100.x.x.x  # Use the IP from tailscale ip
```

### Usage Examples

#### **SSH Between Laptops**
```bash
# From gti to transporter (or vice versa)
ssh tom@transporter-tailscale-ip

# Example with typical Tailscale IP
ssh tom@100.64.0.2
```

#### **File Sharing**
```bash
# Copy files between laptops securely
scp file.txt tom@100.64.0.2:~/Documents/

# Or use rsync for directories
rsync -av ~/Projects/ tom@100.64.0.2:~/Projects/
```

#### **Development Server Access**
```bash
# Run a development server on one laptop
npm run dev  # or python -m http.server, etc.

# Access from the other laptop
curl http://100.64.0.2:3000  # or any port your server uses
```

#### **Subnet Routing** (Optional)
If you want to access your home network from anywhere:
```bash
# On a laptop at home, enable subnet routing
sudo tailscale up --advertise-routes=192.168.1.0/24

# Approve the route in Tailscale admin console
# Now you can access home devices from anywhere
```

### Security Features
- **Encrypted**: All traffic encrypted end-to-end
- **Direct Connections**: NAT traversal for peer-to-peer connections
- **Key Rotation**: Automatic WireGuard key rotation
- **Device Approval**: You control which devices can join

### Tailscale Admin Console
- **URL**: [login.tailscale.com](https://login.tailscale.com)
- **Features**:
  - See all your devices
  - Approve new devices
  - Enable/disable subnet routing
  - Set up ACLs (access control lists)
  - Monitor traffic and connection status

## 🔧 **System Integration**

### Automatic Startup
Both features start automatically:
- **ZRAM**: Enabled during boot, managed by systemd
- **Tailscale**: Service starts automatically, maintains connections

### Firewall Configuration
The Tailscale mixin automatically:
- Trusts the `tailscale0` interface
- Opens UDP port 41641 for Tailscale
- Enables IP forwarding for subnet routing

### Configuration Files
- **ZRAM**: Configured in `nixos/_mixins/services/base.nix`
- **Tailscale**: Configured in `nixos/_mixins/services/tailscale.nix`

## 🛠️ **Troubleshooting**

### ZRAM Issues
```bash
# Check if ZRAM is active
cat /proc/swaps

# View ZRAM device status
sudo zramctl

# If ZRAM isn't working, check systemd status
systemctl status systemd-zram-setup@zram0.service
```

### Tailscale Issues
```bash
# Check Tailscale service status
systemctl status tailscaled

# View Tailscale logs
journalctl -u tailscaled -f

# Re-authenticate if connection issues
sudo tailscale up --force-reauth

# Check network connectivity
tailscale ping other-device-name
```

### Common Solutions
1. **Tailscale not connecting**: Check firewall settings and ensure UDP 41641 is open
2. **ZRAM not active**: Verify the service started correctly during boot
3. **Authentication issues**: Use `tailscale up --force-reauth` to re-authenticate

## 🎯 **Next Steps**

### After Your Next Rebuild
1. **ZRAM**: Will automatically be active with better compression
2. **Tailscale**: Run `sudo tailscale up` on both laptops to set up the mesh

### Optional Enhancements
- **Mobile Apps**: Install Tailscale on your phone for remote access
- **Exit Nodes**: Use one laptop as an exit node for secure browsing
- **MagicDNS**: Enable for easy device name resolution (gti.tailnet, transporter.tailnet)

Both features integrate seamlessly with your existing mixin architecture and provide immediate benefits for performance (ZRAM) and connectivity (Tailscale)!