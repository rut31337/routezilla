#!/bin/bash

# install docker, useful utilities, and quagga image

dnf -y install git docker bridge-utils telnet net-tools
systemctl enable docker
systemctl start docker
#docker pull abaranov/quagga
cd
git clone https://github.com/rut31337/docker-quagga.git
cd docker-quagga
./build.sh
bash -c "curl https://raw.githubusercontent.com/jpetazzo/pipework/master/pipework" > ~/pipework
chmod +x ~/pipework
