#!/bin/bash

# must be called from the top level

# check input arguments
if [ "$#" -ne 2 ]; then
    echo "Please specify pem-key location and cluster name!" && exit 1
fi

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
REGION=${AWS_DEFAULT_REGION:=us-west-2}

source ${PEG_ROOT}/util.sh

PEMLOC=$1
CLUSTER_NAME=$2

# check if pem-key location is valid
if [ ! -f $PEMLOC ]; then
  echo "pem-key does not exist!" && exit 1
fi

get_cluster_publicdns_arr ${CLUSTER_NAME}

single_script="${PEG_ROOT}/config/zookeeper/setup_single.sh"

# Install and configure nodes for zookeeper
SERVER_NUM=1
for dns in "${PUBLIC_DNS_ARR[@]}"; do
  args="$SERVER_NUM "${PUBLIC_DNS_ARR[@]}""
  run_script_on_node ${PEMLOC} ${dns} ${single_script} ${args}
  SERVER_NUM=$(($SERVER_NUM+1))
done

wait

echo "Zookeeper configuration complete!" 
