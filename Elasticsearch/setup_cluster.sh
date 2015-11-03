#!/bin/bash

# check input arguments
if [ "$#" -ne 4 ]; then
    echo "Please specify pem-key location, AWS region, AWS EC2 security group name and the Elasticsearch Cluster Name!" && exit 1
fi

# get input arguments [aws region, pem-key location]
PEMLOC=$1
REGION=$2
EC2_GROUP=$3
ES_NAME=$4
AWS_ACCESS_KEY=$(awk -F"= " 'NR==2 {print $2}' ~/.boto)
AWS_SECRET_KEY=$(awk -F"= " 'NR==3 {print $2}' ~/.boto)

# check if pem-key location is valid
if [ ! -f $PEMLOC ]; then
    echo "pem-key does not exist!" && exit 1
fi

# import AWS public DNS's
DNS=()
while read line; do
    DNS+=($line)
done < public_dns

# Install and configure nodes for elasticsearch
for dns in "${DNS[@]}"
do
    echo $dns
    ssh -o "StrictHostKeyChecking no" -i $PEMLOC ubuntu@$dns 'bash -s' < Elasticsearch/setup_single.sh $REGION $AWS_ACCESS_KEY $AWS_SECRET_KEY $EC2_GROUP $ES_NAME &
done

wait

for dns in "${DNS[@]}"
do
    echo $dns
    ssh -o "StrictHostKeyChecking no" -i $PEMLOC ubuntu@$dns 'sudo /usr/local/elasticsearch/bin/elasticsearch &'
done

echo "Elasticsearch setup complete!"

