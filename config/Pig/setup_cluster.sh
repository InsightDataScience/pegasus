#!/bin/bash

# check input arguments
if [ "$#" -ne 2 ]; then
    echo "Please specify the pem-key location and the cluster name" && exit 1
fi

PEMLOC=$1
CLUSTER_NAME=$2

# check if pem-key location is valid
if [ ! -f $PEMLOC ]; then
    echo "pem-key does not exist!" && exit 1
fi

if [ ! -d tmp/$CLUSTER_NAME ]; then
    echo "cluster does not exist!" && exit 1
fi

MASTER_DNS=$(sed -n '1p' tmp/$CLUSTER_NAME/public_dns)

ssh -i $PEMLOC ubuntu@$MASTER_DNS 'bash -s' < config/pig/setup_pig.sh

