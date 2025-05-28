#!/bin/bash
set -e

sleep 20

echo "[$(date)] Starting NFS VM..." 
/usr/bin/VBoxManage startvm "nfs" --type headless || {
    echo "Failed to start nfs VM"
    exit 1
}
echo "[$(date)] Waiting for NFS VM to be running..."


while true; do
    state=$(/usr/bin/VBoxManage showvminfo "nfs" --machinereadable | grep -i ^VMState= | cut -d= -f2 | tr -d '"')
    echo "[$(date)] NFS state: $state"
    if [[ $state == "running" ]]; then
        echo "[$(date)] NFS VM is running."
        break
    fi
    sleep 2
done

echo "[$(date)] Starting minime VM..."
/usr/bin/VBoxManage startvm "minime" --type headless
