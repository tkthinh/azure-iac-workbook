#!/bin/bash
set -euo pipefail

USERNAME="azureuser"
# Supply an explicit public key through the environment; never hardcode one.
PUBKEY="${PUBKEY:?Set PUBKEY to the intended SSH public key before running}"

HOME_DIR="/home/${USERNAME}"
SSH_DIR="${HOME_DIR}/.ssh"
AUTH_KEYS="${SSH_DIR}/authorized_keys"

# Verify user exists
if ! id "${USERNAME}" >/dev/null 2>&1; then
    echo "User ${USERNAME} does not exist"
    exit 1
fi

# Create .ssh directory
mkdir -p "${SSH_DIR}"
touch "${AUTH_KEYS}"

# Add key only if not already present
if ! grep -Fxq "${PUBKEY}" "${AUTH_KEYS}"; then
    echo "${PUBKEY}" >> "${AUTH_KEYS}"
fi

# Correct ownership and permissions
chown -R "${USERNAME}:${USERNAME}" "${SSH_DIR}"
chmod 700 "${SSH_DIR}"
chmod 600 "${AUTH_KEYS}"

echo "SSH public key installed for ${USERNAME}"
