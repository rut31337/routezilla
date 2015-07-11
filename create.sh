#!/bin/bash

# Create 1000 quagga routers

rm -rf ~/volumes

echo "Creating quagga configuration files..."

for hn in {0001..1000}
do
  mkdir -p ~/volumes/quagga/R$hn
  echo -e "hostname R$hn\npassword zebra" |tee ~/volumes/quagga/R$hn/{ospfd,bgpd,zebra}.conf > /dev/null
done

echo "Setting up configuration file security..."
chcon -Rvt svirt_sandbox_file_t ~/volumes/quagga 1> /dev/null
setfacl -R -m u:100:rwx ~/volumes/quagga 1> /dev/null
setfacl -R -m g:101:rwx ~/volumes/quagga 1> /dev/null

echo "Creating quagga containers..."
f=1
s=1
for hn in {0001..1000}
do
  #docker run -P --hostname=R$hn --name=R$hn -d -v ~/volumes/quagga/R$hn:/etc/quagga abaranov/quagga 1> /dev/null
  docker run -P --hostname=R$hn --name=R$hn -d -v ~/volumes/quagga/R$hn:/etc/quagga rut31337/docker-quagga 1> /dev/null
  ~/pipework br0 R$hn 172.16.$f.$s/12
  echo "Created router R$hn with IP address 172.16.$f.$s"
  ((s=s+1))
  if [ $s -ge 255 ]
  then
    ((f=f+1))
    if [ $f -ge 255 ]
    then
      echo "Error, out of IPs!"
      exit 1
    fi
    s=1
  fi
done

ifconfig br0 172.16.0.1/12
