#!/bin/bash

set -e

# Change SSH port to 2222
SSH_CONFIG="/etc/ssh/sshd_config"

# Backup original config
cp "$SSH_CONFIG" "${SSH_CONFIG}.bak_$(date +%F_%T)"

# Update or add Port line
if grep -q "^Port " "$SSH_CONFIG"; then
    sed -i 's/^Port .*/Port 2222/' "$SSH_CONFIG"
else
    echo "Port 2222" >> "$SSH_CONFIG"
fi

# Allow new port through UFW if active
if ufw status | grep -q "Status: active"; then
    ufw allow 2222/tcp
    ufw delete allow 22/tcp || true
fi

# Restart SSH service
systemctl restart sshd

echo "SSH port changed to 2222. Reconnect using: ssh -p 2222 user@server"
