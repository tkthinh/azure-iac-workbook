#!/usr/bin/env bash
set -euo pipefail

NEW_PORT=2222
SSHD_CONFIG="/etc/ssh/sshd_config"
BACKUP="/etc/ssh/sshd_config.bak.$(date +%F-%H%M%S)"

if [[ $EUID -ne 0 ]]; then
  echo "Run as root" >&2
  exit 1
fi

if [[ ! -f "$SSHD_CONFIG" ]]; then
  echo "Missing $SSHD_CONFIG" >&2
  exit 1
fi

cp -a "$SSHD_CONFIG" "$BACKUP"
echo "Backup created: $BACKUP"

# Remove existing active Port lines
sed -i '/^[[:space:]]*Port[[:space:]]\+[0-9]\+[[:space:]]*$/d' "$SSHD_CONFIG"

# Add new port
printf '\nPort %s\n' "$NEW_PORT" >> "$SSHD_CONFIG"

# Validate SSH config
if ! sshd -t -f "$SSHD_CONFIG"; then
  echo "Config invalid, restoring backup" >&2
  cp -a "$BACKUP" "$SSHD_CONFIG"
  exit 1
fi

# Configure SELinux to allow sshd on the new port
if command -v getenforce >/dev/null 2>&1; then
  SELINUX_MODE="$(getenforce || true)"
  if [[ "$SELINUX_MODE" != "Disabled" ]]; then
    if ! command -v semanage >/dev/null 2>&1; then
      echo "semanage not found. Install policycoreutils-python-utils first." >&2
      echo "On RHEL 8/9: dnf install -y policycoreutils-python-utils" >&2
      exit 1
    fi

    if semanage port -l | grep -E '^ssh_port_t\b' | awk '{print $4}' | tr ',' '\n' | grep -qx "$NEW_PORT"; then
      echo "SELinux already allows port $NEW_PORT for ssh"
    else
      semanage port -a -t ssh_port_t -p tcp "$NEW_PORT" || \
      semanage port -m -t ssh_port_t -p tcp "$NEW_PORT"
    fi
  fi
fi

# Open firewall port if firewalld is running
if systemctl is-active --quiet firewalld; then
  firewall-cmd --permanent --add-port="${NEW_PORT}/tcp"
  firewall-cmd --reload
fi

systemctl restart sshd

echo "SSH port changed to $NEW_PORT"
echo "Test with:"
echo "ssh -p $NEW_PORT youruser@yourhost"