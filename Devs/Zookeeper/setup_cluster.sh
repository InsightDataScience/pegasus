#!/bin/bash

# must be called from the top level

# check input arguments
if [ "$#" -ne 1 ]; then
    echo "Please specify pem-key location!" && exit 1
fi

# get input arguments [aws region, pem-key location]
PEMLOC=$1

# check if pem-key location is valid
if [ ! -f $PEMLOC ]; then
    echo "pem-key does not exist!" && exit 1
fi

# import AWS public DNS's
DNS=()
while read line; do
    DNS+=($line)
done < public_dns

# Install and configure nodes for zookeeper
SERVER_NUM=1
for dns in "${DNS[@]}"
do
    echo $dns
    ssh -o "StrictHostKeyChecking no" -i $PEMLOC ubuntu@$dns 'bash -s' < Zookeeper/setup_single.sh $SERVER_NUM "${DNS[@]}" &
    SERVER_NUM=$(echo "$SERVER_NUM+1" | bc)
done

wait

echo "Zookeeper setup complete!" 
