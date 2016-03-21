#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Please specify cluster name!" && exit 1
fi

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

CLUSTER_NAME=$1

get_cluster_publicdns_arr ${CLUSTER_NAME}

MASTER_DNS=${PUBLIC_DNS_ARR[0]}
NUM_WORKERS=${#PUBLIC_DNS_ARR[@]}

# Configure base Presto coordinator and workers
single_script="${PEG_ROOT}/config/presto/setup_single.sh"
args="$MASTER_DNS $NUM_WORKERS"
for dns in "${PUBLIC_DNS_ARR[@]}"; do
  run_script_on_node ${dns} ${single_script} ${args} &
done

wait

# Configure Presto coordinator and workers
coordinator_script="${PEG_ROOT}/config/presto/config_coordinator.sh"
run_script_on_node ${MASTER_DNS} ${coordinator_script}

worker_script="${PEG_ROOT}/config/presto/config_worker.sh"
for dns in "${PUBLIC_DNS_ARR[@]:1}"
do
  run_script_on_node ${dns} ${worker_script} &
done

wait

cli_script="${PEG_ROOT}/config/presto/setup_cli.sh"
run_script_on_node ${MASTER_DNS} ${cli_script}

echo "Presto configuration complete!"
echo "NOTE: Presto versions after 0.86 require Java 8"

