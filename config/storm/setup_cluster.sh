#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Please specify cluster name!" && exit 1
fi

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

CLUSTER_NAME=$1
WORKERS_PER_NODE=4

get_cluster_publicdns_arr ${CLUSTER_NAME}

MASTER_DNS=${PUBLIC_DNS_ARR[0]}
WORKER_DNS=${PUBLIC_DNS_ARR[@]:1}

# Configure base Storm nimbus and supervisors
single_script="${PEG_ROOT}/config/storm/setup_single.sh"
args="${WORKERS_PER_NODE} ${MASTER_DNS} ${WORKER_DNS}"
for dns in "${PUBLIC_DNS_ARR[@]}"; do
  run_script_on_node ${dns} ${single_script} ${args} &
done

wait

echo "Storm configuration complete!"

