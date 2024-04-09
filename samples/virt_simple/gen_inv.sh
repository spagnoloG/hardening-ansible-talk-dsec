#!/bin/bash

N=5

echo "[all]" >> inventory.ini

for i in $(seq 1 $N);
do
    VM_NAME="ubuntu-server-$i"
    
    SSH_CONFIG=$(vagrant ssh-config $VM_NAME)
    
    HOST_NAME=$(echo "$SSH_CONFIG" | grep HostName | awk '{print $2}')
    USER=$(echo "$SSH_CONFIG" | grep -w User | awk '{print $2}')
    PORT=$(echo "$SSH_CONFIG" | grep Port | awk '{print $2}')
    IDENTITY_FILE=$(echo "$SSH_CONFIG" | grep IdentityFile | awk '{print $2}')
 
    echo "$VM_NAME ansible_host=$HOST_NAME ansible_port=$PORT ansible_user=$USER ansible_private_key_file=$IDENTITY_FILE ansible_ssh_common_args='-o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null'" >> inventory.ini
done

