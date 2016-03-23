#!/bin/bash

# must be called from the top level

# check input arguments
if [ "$#" -ne 1 ]; then
    echo "Please specify cluster name!" && exit 1
fi

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

CLUSTER_NAME=$1

MASTER_DNS=$(fetch_cluster_master_public_dns ${CLUSTER_NAME})
PUBLIC_DNS=$(fetch_cluster_public_dns ${CLUSTER_NAME})
HOSTNAMES=$(fetch_cluster_hostnames ${CLUSTER_NAME})

single_script="${PEG_ROOT}/config/alluxio/setup_single.sh"
args="${HOSTNAMES}"
# Install Alluxio on master and slaves
for dns in ${PUBLIC_DNS}
do
  run_script_on_node ${dns} ${single_script} ${args} &
done

wait

format_script="${PEG_ROOT}/config/alluxio/format_fs.sh"
run_script_on_node ${MASTER_DNS} ${format_script}

echo "Alluxio configuration complete!"
