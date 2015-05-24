#!/bin/bash

# check input arguments
if [ "$#" -ne 4 ]; then
    echo "Please specify pem-key location, AWS region, AWS cluster name and AWS EC2 security group name" && exit 1
fi

PEMLOC=$1

# check if pem-key location is valid
if [ ! -f $PEMLOC ]; then
    echo "pem-key does not exist!" && exit 1
fi

REGION=$2
CLUSTERNAME=$3
EC2_GROUP=$4

python fetch_instances.py $REGION $CLUSTERNAME

cd Elasticsearch

./setup_elasticsearch_cluster.sh $PEMLOC $REGION $EC2_GROUP
