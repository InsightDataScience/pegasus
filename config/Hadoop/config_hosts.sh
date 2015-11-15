#!/bin/bash

MASTER_DNS=$1; shift
MASTER_NAME=$1; shift
SLAVE_DNS_NAME=( "$@" )
LEN=${#SLAVE_DNS_NAME[@]}
HALF=$(echo "$LEN/2" | bc)
SLAVE_DNS=( "${SLAVE_DNS_NAME[@]:0:$HALF}" )
SLAVE_NAME=( "${SLAVE_DNS_NAME[@]:$HALF:$HALF}" )

# add for additional datanodes
sudo sed -i '2i '"$MASTER_DNS"' '"$MASTER_NAME"'' /etc/hosts

for (( i=0; i<$HALF; i++))
do
    echo $i ${SLAVE_DNS[$i]} ${SLAVE_NAME[$i]}
    sudo sed -i '3i '"${SLAVE_DNS[$i]}"' '"${SLAVE_NAME[$i]}"'' /etc/hosts
done

