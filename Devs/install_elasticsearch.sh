#!/bin/bash

# check input arguments
if [ "$#" -ne 3 ]; then
    echo "Please specify pem-key location, AWS region, and AWS EC2 security group name" && exit 1
fi

PEMLOC=$1

# check if pem-key location is valid
if [ ! -f $PEMLOC ]; then
    echo "pem-key does not exist!" && exit 1
fi

REGION=$2
EC2_GROUP=$3

Elasticsearch/setup_cluster.sh $PEMLOC $REGION $EC2_GROUP
