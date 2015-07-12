#!/bin/bash

# kill and remove all containers

source rz.conf

for hn in $(eval echo {$low..$hi})
do
  docker rm -f R$hn
done
rm -rf ~/volumes
