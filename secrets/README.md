# Secrets Management with sops-nix

This directory contains encrypted secrets managed by [sops-nix](https://github.com/Mic92/sops-nix).

## 🔑 Setup

The age key is located at `~/.config/sops/age/keys.txt` and was generated with:
```bash
age-keygen -o ~/.config/sops/age/keys.txt
```

Public key: `age1vvqsmuze45cqpuzlm4cyzh05g6wy58uq35lzak4stqc3lgrlxseq4e3rfr`

## 📝 Editing Secrets

To edit the encrypted secrets file:
```bash
# From the repository root
nix develop -c sops secrets/secrets.yaml
```

## 🔐 Available Secrets

The `secrets.yaml` file contains encrypted values for:

- `user_password_hash` - User account password hash
- `ssh_host_ed25519_key` - SSH host private key
- `ssh_host_ed25519_key_pub` - SSH host public key
- `github_token` - GitHub API token
- `anthropic_api_key` - Anthropic API key
- `wireguard_private_key` - WireGuard VPN private key
- `postgres_password` - PostgreSQL database password
- `nextcloud_admin_password` - Nextcloud admin password

## 🚀 Using Secrets in NixOS

To use a secret in your NixOS configuration:

1. **Add the secret definition** in `nixos/_mixins/services/secrets.nix`:
```nix
sops.secrets."my_secret" = {
  owner = "myuser";
  group = "mygroup";
  mode = "0400";
};
```

2. **Reference the secret** in your service configuration:
```nix
services.myservice = {
  enable = true;
  passwordFile = config.sops.secrets."my_secret".path;
};
```

## 🛡️ Security Notes

- **Never commit unencrypted secrets** to git
- **Encrypted secrets are safe** to commit to version control
- **Age key should be backed up** securely and separately
- **Secrets are decrypted at runtime** during NixOS activation
- **Secrets are not stored in the Nix store** (they're symlinked from `/run/secrets/`)

## 🔄 Common Operations

### Add a new secret:
```bash
# Edit the secrets file and add your new secret
nix develop -c sops secrets/secrets.yaml

# Add the secret configuration to secrets.nix
# Rebuild your system
sudo nixos-rebuild switch --flake .#gti
```

### Rotate the age key:
```bash
# Generate new key
age-keygen -o ~/.config/sops/age/keys_new.txt

# Update .sops.yaml with new public key
# Re-encrypt secrets with new key
nix develop -c sops updatekeys secrets/secrets.yaml

# Replace old key
mv ~/.config/sops/age/keys_new.txt ~/.config/sops/age/keys.txt
```

### Share secrets with team members:
```bash
# Add their age public key to .sops.yaml
# Re-encrypt the secrets file
nix develop -c sops updatekeys secrets/secrets.yaml
```

## 🎯 Examples

See the commented examples in `nixos/_mixins/services/secrets.nix` for common use cases like:
- User password hashes
- SSH host keys
- API tokens
- Database passwords
- Network credentials