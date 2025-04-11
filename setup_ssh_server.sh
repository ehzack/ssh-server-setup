#!/bin/bash
# ------------------------------------------------------------------------------
# Script Name: setup_ssh.sh
#
# Description:
#   This script sets up a key-based SSH access for a remote server by:
#     - Generating a single RSA key (if not already available)
#     - Deploying the public key to the server using ssh-copy-id (if not already set up)
#     - Creating or updating an entry in ~/.ssh/config so that you can connect
#       using a simple alias (e.g., "ssh server1")
#
# Usage:
#   ./setup_ssh.sh <server_alias> <server_ip> <username>
#
# Example:
#   ./setup_ssh.sh server1 192.168.1.100 root
#
# Requirements:
#   - Bash, ssh, ssh-keygen, ssh-copy-id
#
# License: MIT License (see LICENSE file for details)
# ------------------------------------------------------------------------------

set -e  # Exit script on any error

# Define paths and filenames
SSH_DIR="$HOME/.ssh"
SSH_KEY="$SSH_DIR/server_id_rsa"   # Single RSA key for all servers
SSH_CONFIG="$SSH_DIR/config"

# Ensure the .ssh directory exists with proper permissions
if [ ! -d "$SSH_DIR" ]; then
    mkdir -p "$SSH_DIR"
    chmod 700 "$SSH_DIR"
fi

# Verify that exactly three arguments are provided
if [ "$#" -ne 3 ]; then
    echo "[ERROR] Usage: $0 <server_alias> <server_ip> <username>"
    echo "Example: $0 server1 192.168.1.100 root"
    exit 1
fi

ALIAS="$1"
HOST="$2"
USER="$3"

# Generate an SSH key if it does not exist
if [ ! -f "$SSH_KEY" ]; then
    echo "[INFO] No SSH key found at $SSH_KEY. Generating a new RSA key..."
    ssh-keygen -t rsa -b 4096 -f "$SSH_KEY" -N ""
fi

echo "[INFO] Configuring server: $ALIAS ($HOST) with user $USER..."

# Validate that host and user are not empty
if [[ -z "$USER" || -z "$HOST" ]]; then
    echo "[ERROR] Invalid user or host. Both must be provided."
    exit 1
fi

# Check if the server accepts passwordless SSH (i.e., key-based auth already set up)
if ssh -o BatchMode=yes -o ConnectTimeout=5 "$USER@$HOST" "echo Connected" 2>/dev/null; then
    echo "[INFO] SSH key-based authentication appears to be active on $HOST."
else
    echo "[INFO] Server does not appear to have key-based access. Attempting to copy public key..."
    ssh-copy-id -i "$SSH_KEY.pub" "$USER@$HOST"
    if [ $? -ne 0 ]; then
        echo "[ERROR] Failed to copy SSH key to $USER@$HOST. Verify that the server is reachable and allows SSH."
        exit 1
    fi
fi

# Ensure the SSH config file exists and has correct permissions
if [ ! -f "$SSH_CONFIG" ]; then
    touch "$SSH_CONFIG"
    chmod 600 "$SSH_CONFIG"
fi

# If an entry for this alias exists, remove the old configuration block.
if grep -q "Host $ALIAS" "$SSH_CONFIG"; then
    echo "[INFO] Found an existing SSH config entry for alias '$ALIAS'. Updating it..."
    # Use awk to remove the block that starts with the Host line for the given alias.
    awk -v alias="$ALIAS" '
      BEGIN { skip = 0 }
      /^Host / {
          if ($2 == alias) {
              skip = 1; next
          } else {
              skip = 0
          }
      }
      { if (!skip) print $0 }
    ' "$SSH_CONFIG" > "$SSH_CONFIG.tmp" && mv "$SSH_CONFIG.tmp" "$SSH_CONFIG"
fi

# Append the new SSH configuration entry to ~/.ssh/config
cat <<EOL >> "$SSH_CONFIG"

Host $ALIAS
    HostName $HOST
    User $USER
    IdentityFile $SSH_KEY
    Port 22
EOL

echo "[SUCCESS] SSH configuration for '$ALIAS' added successfully!"
echo "          You can now connect using: ssh $ALIAS"

exit 0
