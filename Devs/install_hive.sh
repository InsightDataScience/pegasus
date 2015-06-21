#!/bin/bash

# check input arguments
if [ "$#" -ne 3 ]; then
    echo "Please specify the pem-key location, AWS region, and AWS cluster" && exit 1
fi

PEMLOC=$1

# check if pem-key location is valid
if [ ! -f $PEMLOC ]; then
    echo "pem-key does not exist!" && exit 1
fi

REGION=$2
CLUSTERNAME=$3

python fetch_instances.py $REGION $CLUSTERNAME

MASTER_DNS=$(sed -n '1p' public_dns)

ssh -i $PEMLOC ubuntu@$MASTER_DNS 'bash -s' < Hive/setup_hive.sh

