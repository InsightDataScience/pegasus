#!/bin/bash

# check input arguments
if [ "$#" -ne 2 ]; then
    echo "Please specify pem-key location, ElasticSearch DNS, Kibana DNS" && exit 1
fi

PEMLOC=$1

# check if pem-key location is valid
if [ ! -f $PEMLOC ]; then
    echo "pem-key does not exist!" && exit 1
fi

ELASTICSEARCH_DNS=$2
KIBANA_DNS=$3

ssh -o "StrictHostKeyChecking no" -i $PEMLOC ubuntu@$KIBANA_DNS 'bash -s' < Kibana/setup_kibana.sh $ELASTICSEARCH_DNS
