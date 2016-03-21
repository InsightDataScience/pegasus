#!/bin/bash

# must be called from the top level

# check input arguments
if [ "$#" -ne 2 ]; then
    echo "Please specify pem-key location and cluster name!" && exit 1
fi

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..

source ${PEG_ROOT}/util.sh

# get input arguments [aws region, pem-key location]
PEMLOC=$1
CLUSTER_NAME=$2

# check if pem-key location is valid
if [ ! -f $PEMLOC ]; then
    echo "pem-key does not exist!" && exit 1
fi

get_cluster_publicdns_arr ${CLUSTER_NAME}

script=${PEG_ROOT}/install/environment/install_env.sh

# Install environment packages to master and slaves
for dns in "${PUBLIC_DNS_ARR[@]}"; do
  run_script_on_node ${PEMLOC} ${dns} ${script} &
done

wait

echo "Environment installed!"
