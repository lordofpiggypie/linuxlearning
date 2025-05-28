#!/bin/bash

CONNECTION_NAME=$(nmcli -t -f NAME,TYPE con show --active | awk -F: '$2=="ethernet"{print $1; exit}')

sudo nmcli connection modify enp0s3 ipv4.addresses 192.168.1.232/24 
sudo nmcli connection modify enp0s3 ipv4.gateway 192.168.1.254 
sudo nmcli connection modify enp0s3 ipv4.dns "8.8.8.8 8.8.4.4" 
sudo nmcli connection modify enp0s3 ipv4.method manual 
sudo nmcli connection down enp0s3 && sudo nmcli connection up enp0s3

you were at nfs firewall