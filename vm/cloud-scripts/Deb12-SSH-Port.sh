#!/usr/bin/env bash
set -euo pipefail

NEW_PORT=2222
SSHD_CONFIG="/etc/ssh/sshd_config"
BACKUP="/etc/ssh/sshd_config.bak.$(date +%F-%H%M%S)"

if [[ $EUID -ne 0 ]]; then
  echo "Run as root." >&2
  exit 1
fi

if [[ ! -f "$SSHD_CONFIG" ]]; then
  echo "sshd_config not found: $SSHD_CONFIG" >&2
  exit 1
fi

cp -a "$SSHD_CONFIG" "$BACKUP"
echo "Backup saved to: $BACKUP"

# Remove existing active Port lines
sed -i '/^[[:space:]]*Port[[:space:]]\+[0-9]\+[[:space:]]*$/d' "$SSHD_CONFIG"

# Add desired port
printf '\nPort %s\n' "$NEW_PORT" >> "$SSHD_CONFIG"

# Validate config before applying
if ! sshd -t -f "$SSHD_CONFIG"; then
  echo "Invalid sshd config. Restoring backup." >&2
  cp -a "$BACKUP" "$SSHD_CONFIG"
  exit 1
fi

# Open firewall port if UFW is installed/enabled
if command -v ufw >/dev/null 2>&1; then
  ufw allow "$NEW_PORT/tcp" || true
fi

systemctl restart ssh

echo "SSH port changed to $NEW_PORT"
echo "Test with: ssh -p $NEW_PORT youruser@yourhost"