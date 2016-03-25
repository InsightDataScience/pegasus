#!/bin/bash

if [ "$#" -ne 1 ]; then
  echo "Please specify cluster name!" && exit 1
fi

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

CLUSTER_NAME=$1

PUBLIC_DNS=$(fetch_cluster_public_dns ${CLUSTER_NAME})

MASTER_DNS=$(fetch_cluster_master_public_dns ${CLUSTER_NAME})
WORKER_DNS=$(fetch_cluster_worker_public_dns ${CLUSTER_NAME})

# Install and configure Spark on all nodes
for dns in ${PUBLIC_DNS}; do
  single_script="${PEG_ROOT}/config/spark/setup_single.sh"
  args="${dns}"
  run_script_on_node ${dns} ${single_script} ${args} &
done

wait

worker_script="${PEG_ROOT}/config/spark/config_workers.sh"
args="${WORKER_DNS}"
run_script_on_node ${MASTER_DNS} ${worker_script} ${args}
