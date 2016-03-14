#!/bin/bash

# must be called from the top level

# check input arguments
if [ "$#" -ne 2 ]; then
    echo "Please specify pem-key location and cluster name!" && exit 1
fi

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
REGION=${AWS_DEFAULT_REGION:=us-west-2}

source ${PEG_ROOT}/util.sh

# get input arguments [aws region, pem-key location]
PEMLOC=$1
CLUSTER_NAME=$2

# check if pem-key location is valid
if [ ! -f $PEMLOC ]; then
  echo "pem-key does not exist!" && exit 1
fi

get_cluster_publicdns_arr ${CLUSTER_NAME}

MASTER_DNS=${PUBLIC_DNS_ARR[0]}
NUM_WORKERS=${#PUBLIC_DNS_ARR[@]}

# Configure base Presto coordinator and workers
single_script="${PEG_ROOT}/config/presto/setup_single.sh"
args="$MASTER_DNS $NUM_WORKERS"
for dns in "${PUBLIC_DNS_ARR[@]}"; do
  run_script_on_node ${PEMLOC} ${dns} ${single_script} ${args} &
done

wait

# Configure Presto coordinator and workers
coordinator_script="${PEG_ROOT}/config/presto/config_coordinator.sh"
run_script_on_node ${PEMLOC} ${MASTER_DNS} ${coordinator_script}

worker_script="${PEG_ROOT}/config/presto/config_worker.sh"
for dns in "${PUBLIC_DNS_ARR[@]:1}"
do
  run_script_on_node ${PEMLOC} ${dns} ${worker_script} &
done

wait

cli_script="${PEG_ROOT}/config/presto/setup_cli.sh"
run_script_on_node ${PEMLOC} ${MASTER_DNS} ${cli_script}

echo "Presto configuration complete!"
echo "NOTE: Presto versions after 0.86 require Java 8"

