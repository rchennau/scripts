#!/bin/bash
# This script creates a 20 gig swap file for ubuntu
# Source: [How to Create a Swap File on Ubuntu 18.04]

# Check the current swap status
sudo swapon --show

# Create a 20 gig file for swap
sudo fallocate -l 20G /workspace/swapfile

# Adjust the permissions of the file
sudo chmod 600 /workspace/swapfile

# Set up the swap space
sudo mkswap /workspace/swapfile

# Enable the swap file
sudo swapon /workspace/swapfile

# Make the swap file permanent by editing the /etc/fstab file
echo '/workspace/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Verify that the swap file is active
sudo swapon --show

# Check the amount of swap available
free -h

