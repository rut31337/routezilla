sudo bash

for hn in {0001..1000}
do
  docker kill R$hn
  docker rm R$hn
done
rm -rf ~/volumes