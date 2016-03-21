#!/bin/bash

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

# check input arguments
if [ "$#" -ne 2 ]; then
    echo "Please specify pem-key location, cluster name, AWS region!" && exit 1
fi

# get input arguments [aws region, pem-key location]
PEMLOC=$1
CLUSTER_NAME=$2

# check if pem-key location is valid
if [ ! -f $PEMLOC ]; then
    echo "pem-key does not exist!" && exit 1
fi

get_cluster_publicdns_arr ${CLUSTER_NAME}

for dns in "${PUBLIC_DNS_ARR[@]}"
do
  echo $dns
  ssh -o "StrictHostKeyChecking no" -i $PEMLOC ${REM_USER}@$dns '/usr/local/elasticsearch/bin/elasticsearch -d'
done

echo "Elasticsearch started!"

