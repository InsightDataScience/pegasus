#!/bin/bash

# must be called from the top level

# check input arguments
if [ "$#" -ne 1 ]; then
    echo "Please specify cluster name!" && exit 1
fi

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

CLUSTER_NAME=$1

PUBLIC_DNS=$(fetch_cluster_public_dns ${CLUSTER_NAME})

single_script="${PEG_ROOT}/config/zookeeper/setup_single.sh"

# Install and configure nodes for zookeeper
SERVER_NUM=1
for dns in ${PUBLIC_DNS}; do
  args="$SERVER_NUM ${PUBLIC_DNS}"
  run_script_on_node ${dns} ${single_script} ${args}
  SERVER_NUM=$(($SERVER_NUM+1))
done

wait

echo "Zookeeper configuration complete!" 
