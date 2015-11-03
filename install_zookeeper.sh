#!/bin/bash

# check input arguments
if [ "$#" -ne 2 ]; then
    echo "Please specify pem-key location and cluster name" && exit 1
fi

PEMLOC=$1
INSTANCE_NAME=$2

# check if pem-key location is valid
if [ ! -f $PEMLOC ]; then
    echo "pem-key does not exist!" && exit 1
fi

if [ ! -d tmp/$INSTANCE_NAME ]; then
    echo "cluster does not exist!" && exit 1
fi

Zookeeper/setup_cluster.sh $PEMLOC $INSTANCE_NAME

