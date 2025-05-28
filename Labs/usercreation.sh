#!/bin/bash

USERNAME=labuser1
PASSWORD=$(openssl rand -base64 12)

sudo useradd -m "$USERNAME"
echo "$USERNAME:$PASSWORD" | sudo chpasswd

echo "User $USERNAME created with password: $PASSWORD"
id "$USERNAME"
