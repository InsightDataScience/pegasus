#!/bin/bash

# check input arguments
if [ "$#" -ne 4 ]; then
    echo "Please specify pem-key location, AWS region, AWS cluster name, Node DNS" && exit 1
fi

PEMLOC=$1

# check if pem-key location is valid
if [ ! -f $PEMLOC ]; then
    echo "pem-key does not exist!" && exit 1
fi

REGION=$2
CLUSTERNAME=$3
NODEDNS=$4

python fetch_instances.py $REGION $CLUSTERNAME

ELASTICSEARCHDNS=$(head -n 1 public_dns)

ssh -o "StrictHostKeyChecking no" -i $PEMLOC ubuntu@$NODEDNS 'bash -s' < Kibana/setup_kibana.sh $ELASTICSEARCHDNS
