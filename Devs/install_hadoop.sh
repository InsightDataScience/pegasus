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

SSH/setup_passwordless_ssh.sh $PEMLOC $INSTANCE_NAME

Hadoop/setup_cluster.sh $PEMLOC $INSTANCE_NAME

