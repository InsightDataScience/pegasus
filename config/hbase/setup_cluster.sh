#!/bin/bash

# check input arguments
if [ "$#" -ne 1 ]; then
    echo "Please specify cluster name!" && exit 1
fi

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

CLUSTER_NAME=$1

HOSTNAMES=$(fetch_cluster_hostnames ${CLUSTER_NAME})
PUBLIC_DNS=$(fetch_cluster_public_dns ${CLUSTER_NAME})

MASTER_DNS=$(fetch_cluster_master_public_dns ${CLUSTER_NAME})

# Install HBase on master and slaves
single_script="${PEG_ROOT}/config/hbase/setup_single.sh"
args="$MASTER_DNS ${HOSTNAMES}"
for dns in ${PUBLIC_DNS}; do
  run_script_on_node ${dns} ${single_script} ${args} &
done

wait

echo "HBase configuration complete!"
