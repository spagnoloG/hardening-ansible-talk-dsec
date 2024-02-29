#!/bin/bash

# Name of your Vagrant machine
VM_NAME="virt-simple"

# Generate SSH config for the Vagrant machine
SSH_CONFIG=$(vagrant ssh-config $VM_NAME)

# Parse SSH config to get SSH parameters
HOST_NAME=$(echo "$SSH_CONFIG" | grep HostName | awk '{print $2}')
USER=$(echo "$SSH_CONFIG" | grep User | awk '{print $2}')
PORT=$(echo "$SSH_CONFIG" | grep Port | awk '{print $2}')
IDENTITY_FILE=$(echo "$SSH_CONFIG" | grep IdentityFile | awk '{print $2}')

# Create an Ansible inventory entry
echo "[vagrant]"
echo "$VM_NAME ansible_host=$HOST_NAME ansible_port=$PORT ansible_user=$USER ansible_private_key_file=$IDENTITY_FILE ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'"

