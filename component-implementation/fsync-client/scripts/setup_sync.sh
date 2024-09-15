#!/bin/bash

# Check if environment variables are set
if [ -z "$PUBLIC_KEY" ]; then
  echo "Error: PUBLIC_KEY environment variable is not set."
  exit 1
fi

if [ -z "$PRIVATE_KEY" ]; then
  echo "Error: PRIVATE_KEY environment variable is not set."
  exit 1
fi

# Define the path where you want to store the keys
KEY_DIR="$HOME/.ssh"
PUBLIC_KEY_PATH="$KEY_DIR/id_ed25519.pub"
AUTHORIZED_KEYS_KEY_PATH="$KEY_DIR/authorized_keys"
PRIVATE_KEY_PATH="$KEY_DIR/id_ed25519"

# Create the .ssh directory if it doesn't exist
mkdir -p "$KEY_DIR"
chmod 700 "$KEY_DIR"

# Place the public key
echo "$PUBLIC_KEY" > "$PUBLIC_KEY_PATH"
chmod 644 "$PUBLIC_KEY_PATH"

echo "$PUBLIC_KEY" > "$AUTHORIZED_KEYS_KEY_PATH"
chmod 600 "$PUBLIC_KEY_PATH"

# Place the private key
echo "$PRIVATE_KEY" > "$PRIVATE_KEY_PATH"
chmod 400 "$PRIVATE_KEY_PATH"

# Add the private key to the ssh-agent (if it's running)
if [ -z "$(pgrep ssh-agent)" ]; then
  eval "$(ssh-agent -s)"
fi
ssh-add "$PRIVATE_KEY_PATH"

echo "Keys have been successfully set up."

echo StrictHostKeyChecking no >> /etc/ssh/ssh_config

eval "$(ssh-agent -s)" && ssh-add "$PRIVATE_KEY_PATH"

while ! mutagen sync create --name dags -i .git $FSYNC_SSH_CONNECTION:/volume /volume; do 
  echo "Waiting fsync_vol server to be running"
  sleep 5
done

while true; do mutagen sync list; sleep 30; done