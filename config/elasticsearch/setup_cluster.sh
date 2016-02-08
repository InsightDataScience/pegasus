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
DNS=()
while read line; do
    DNS+=($line)
done < tmp/$INSTANCE_NAME/public_dns

# Install and configure nodes for elasticsearch
for dns in "${DNS[@]}"
do
  ssh -o "StrictHostKeyChecking no" -i $PEMLOC ubuntu@$dns 'bash -s' < config/elasticsearch/setup_single.sh $INSTANCE_NAME $AWS_DEFAULT_REGION $AWS_SECRET_ACCESS_KEY $AWS_ACCESS_KEY_ID &
done

wait

echo "Elasticsearch configuration complete!"

