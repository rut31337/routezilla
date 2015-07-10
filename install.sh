#!/bin/bash

# install docker, useful utilities, and quagga image

sudo bash

dnf -y install git docker bridge-utils telnet
docker pull abaranov/quagga
bash -c "curl https://raw.githubusercontent.com/jpetazzo/pipework/master/pipework" > ~/pipework
chmod +x ~/pipework
