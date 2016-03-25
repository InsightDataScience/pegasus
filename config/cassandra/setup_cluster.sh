#!/bin/bash

# check input arguments
if [ "$#" -ne 1 ]; then
  echo "Please specify cluster name!" && exit 1
fi

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

CLUSTER_NAME=$1

PUBLIC_DNS=$(fetch_cluster_public_dns ${CLUSTER_NAME})
PRIVATE_IP_ARR=($(fetch_cluster_private_ips ${CLUSTER_NAME}))

SEED_IP=$(fetch_cluster_master_private_ip ${CLUSTER_NAME})
SEED_DNS=$(fetch_cluster_master_public_dns ${CLUSTER_NAME})

single_script="${PEG_ROOT}/config/cassandra/setup_single.sh"

IDX=0
for dns in ${PUBLIC_DNS};
do
  args="${CLUSTER_NAME} ${SEED_IP} ${PRIVATE_IP_ARR[$IDX]}"
  run_script_on_node ${dns} ${single_script} ${args} &
  IDX=$(($IDX+1))
done

wait

echo "Cassandra configuration complete!"
