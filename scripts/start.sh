#!bin/bash

file=`cat /etc/mataelanglab/mode`

docker compose --file $file start

cat scripts/web-info.txt