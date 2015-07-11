#!/bin/bash

# Create 1000 quagga routers

hn=0001

rm -rf ~/volumes/quagga/R$hn

echo "Creating quagga configuration files..."

mkdir -p ~/volumes/quagga/R$hn
echo -e "hostname R$hn\npassword zebra" |tee ~/volumes/quagga/R$hn/{ospfd,bgpd,zebra}.conf > /dev/null

echo "Setting up configuration file security..."
chcon -Rvt svirt_sandbox_file_t ~/volumes/quagga/R$hn 1> /dev/null
setfacl -R -m u:100:rwx ~/volumes/quagga/R$hn 1> /dev/null
setfacl -R -m g:101:rwx ~/volumes/quagga/R$hn 1> /dev/null

echo "Creating quagga containers..."
docker run -P --hostname=R$hn --name=R$hn -d -v ~/volumes/quagga/R$hn:/etc/quagga rut31337/docker-quagga 1> /dev/null
~/pipework br0 R$hn 172.16.1.1/12
echo "Created router R$hn with IP address 172.16.1.1"

ifconfig br0 172.16.0.1/12
