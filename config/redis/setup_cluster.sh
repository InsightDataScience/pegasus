#!/bin/bash

# check input arguments
if [ "$#" -ne 2 ]; then
    echo "Please specify pem-key location and cluster name!" && exit 1
fi

# get input arguments [aws region, pem-key location]
PEMLOC=$1
INSTANCE_NAME=$2

# check if pem-key location is valid
if [ ! -f $PEMLOC ]; then
    echo "pem-key does not exist!" && exit 1
fi

# import AWS public DNS's
SEED_DNS=$(head -n 1 tmp/$INSTANCE_NAME/public_dns)
NODE_DNS=()
while read line; do
    NODE_DNS+=($line)
done < tmp/$INSTANCE_NAME/public_dns

# Install and configure nodes for cassandra
IP_CNT=0
for dns in "${NODE_DNS[@]}";
do
    ssh -o "StrictHostKeyChecking no" -i $PEMLOC ubuntu@$dns 'bash -s' < config/redis/setup_single.sh &
done

wait

echo "Redis configuration complete!"
