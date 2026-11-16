#!/bin/bash

# Define the new SSH port
NEW_SSH_PORT="2222" # Replace with your desired port number

# Backup the original sshd_config file
sudo cp /etc/ssh/sshd_config /etc/ssh/sshd_config.bak

# Modify the SSH daemon configuration file
# Remove the existing 'Port 22' line if present and add the new port
sudo sed -i '/^Port /d' /etc/ssh/sshd_config
echo "Port ${NEW_SSH_PORT}" | sudo tee -a /etc/ssh/sshd_config > /dev/null

# Update UFW (Uncomplicated Firewall) rules if UFW is active
if sudo ufw status | grep -q "Status: active"; then
    echo "UFW is active. Updating firewall rules..."
    sudo ufw allow "${NEW_SSH_PORT}/tcp"
    sudo ufw delete allow 22/tcp # Optional: Remove default port rule if not needed
    sudo ufw reload
else
    echo "UFW is not active. No firewall rules updated."
fi

# Restart the SSH service to apply changes
sudo systemctl restart ssh.service

echo "SSH port successfully changed to ${NEW_SSH_PORT}."
echo "Remember to connect with 'ssh -p ${NEW_SSH_PORT} username@your_server_ip'."