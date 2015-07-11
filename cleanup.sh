#!/bin/bash

# kill and remove all containers

for hn in {0001..1000}
do
  docker rm -f R$hn
done
rm -rf ~/volumes
