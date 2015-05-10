#!/bin/bash

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
done < ../public_dns

# Install and configure nodes for kafka
BROKER_ID=0
for dns in "${DNS[@]}"
do
    echo $dns
    ssh -o "StrictHostKeyChecking no" -i $PEMLOC ubuntu@$dns 'bash -s' < setup_kafka.sh $BROKER_ID "${DNS[@]}" &
    BROKER_ID=$(echo "$BROKER_ID+1" | bc)
done

wait

echo "Kafka setup complete!"

