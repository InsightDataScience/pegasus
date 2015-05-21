#!/bin/bash

# check input arguments
if [ "$#" -ne 3 ]; then
    echo "Please specify pem-key location, AWS region, and AWS cluster name" && exit 1
fi

PEMLOC=$1

# check if pem-key location is valid
if [ ! -f $PEMLOC ]; then
    echo "pem-key does not exist!" && exit 1
fi

REGION=$2
CLUSTERNAME=$3

python fetch_instances.py $REGION $CLUSTERNAME

./setup_passwordless_ssh.sh $PEMLOC

cd Hadoop

./setup_hadoop_cluster.sh $PEMLOC

