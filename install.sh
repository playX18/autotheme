#!/bin/bash

# Build the program using cargo
cargo install --path .
cargo install wallust
home_path=$(echo ~)

# Define the service file content
SERVICE_FILE_CONTENT="[Unit]
Description=Autotheme Service

[Service]
ExecStart=$home_path/.cargo/bin/gnome-autotheme
Environment=AUTOTHEME_SCRIPT=$home_path/.bin/autotheme.bash
Environment=RUST_LOG=info
Restart=always

[Install]
WantedBy=default.target"

# Create the systemd user service directory if it doesn't exist
mkdir -p ~/.config/systemd/user

# Write the service file
echo "$SERVICE_FILE_CONTENT" > ~/.config/systemd/user/autotheme.service
mkdir -p ~/.bin
mkdir -p ~/.config/autotheme
# Copy the autotheme.bash script to /usr/local/bin
cp ./autotheme.bash ~/.bin/autotheme.bash
cp wallust.toml ~/.config/autotheme/wallust.toml
cp wallust-light.toml ~/.config/autotheme/wallust-light.toml
cp -r templates/ ~/.config/autotheme/templates
# Reload the systemd manager configuration
systemctl --user daemon-reload

# Enable and start the service
systemctl --user enable autotheme.service
systemctl --user start autotheme.service --now

echo "Autotheme service installed and started successfully."
