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
NUM_WORKERS=$(echo ${WORKER_DNS} | wc -w)

# Configure base Presto coordinator and workers
single_script="${PEG_ROOT}/config/presto/setup_single.sh"
args="$MASTER_DNS $NUM_WORKERS"
for dns in ${PUBLIC_DNS}; do
  run_script_on_node ${dns} ${single_script} ${args} &
done

wait

# Configure Presto coordinator and workers
coordinator_script="${PEG_ROOT}/config/presto/config_coordinator.sh"
run_script_on_node ${MASTER_DNS} ${coordinator_script}

worker_script="${PEG_ROOT}/config/presto/config_worker.sh"
for dns in ${WORKER_DNS}; do
  run_script_on_node ${dns} ${worker_script} &
done

wait

cli_script="${PEG_ROOT}/config/presto/setup_cli.sh"
run_script_on_node ${MASTER_DNS} ${cli_script}

echo "Presto configuration complete!"

