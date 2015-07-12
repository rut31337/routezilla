#!/bin/bash

# Create x quagga routers
low=0001
hi=1000

iptables -F OSPF
iptables -N OSPF
iptables -A OSPF -p 89 -j ACCEPT
brctl addbr br1

rm -rf ~/volumes
mkdir -p ~/volumes

echo "Creating quagga configuration files..."

f=1
s=1
c=1
for hn in $(eval echo {$low..$hi})
do
  mkdir -p ~/volumes/quagga/R$hn
  ((nn=$s-1))
  echo -e "hostname R$hn\npassword zebra" |tee ~/volumes/quagga/R$hn/{bgpd,ospfd,zebra}.conf > /dev/null
  echo -e "router bgp $c\nbgp router-id 172.16.$f.$s\nnetwork 172.20.$f.$nn/30" >> ~/volumes/quagga/R$hn/bgpd.conf
  if [ $s -ge 255 ]
  then
    ((f=$f+1))
    if [ $f -ge 255 ]
    then
      echo "Error, out of IPs!"
      exit 1
    fi
    s=1
  fi
  echo -e "neighbor 172.16.$f.$s remote-as $c" >> ~/volumes/neighbors
  ((s=$s+4))
  ((c=$c+1))
done

c=1
for hn in $(eval echo {$low..$hi})
do
  cat ~/volumes/neighbors |grep -v "remote-as $c$" >> ~/volumes/quagga/R$hn/bgpd.conf
  ((c=$c+1))
done

echo "Setting up configuration file security..."
chcon -Rvt svirt_sandbox_file_t ~/volumes/quagga 1> /dev/null
setfacl -R -m u:100:rwx ~/volumes/quagga 1> /dev/null
setfacl -R -m g:101:rwx ~/volumes/quagga 1> /dev/null

echo "Creating quagga containers..."
f=1
s=1
c=1
for hn in $(eval echo {$low..$hi})
do
  ((nn=$s-1))
  #echo -e "router ospf\nnetwork 172.20.$f.$nn/30 area 0.0.0.0\narea $hn stub" >> ~/volumes/quagga/R$hn/ospfd.conf
  docker run -P --hostname=R$hn --name=R$hn -d -v ~/volumes/quagga/R$hn:/etc/quagga rut31337/docker-quagga 1> /dev/null
  ~/pipework br0 -i eth1 R$hn 172.16.$f.$s/12
  ~/pipework br0 -i eth2 R$hn 172.20.$f.$s/30
  echo "Created router R$hn with IP address 172.16.$f.$s"
  ((s=$s+4))
  if [ $s -ge 255 ]
  then
    ((f=$f+1))
    if [ $f -ge 255 ]
    then
      echo "Error, out of IPs!"
      exit 1
    fi
    s=1
  fi
  ((c=$c+1))
done

ifconfig br0 172.16.0.1/12
