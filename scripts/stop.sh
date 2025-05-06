#!bin/bash

file=`cat /etc/mataelanglab/mode`

docker compose --file $file stop