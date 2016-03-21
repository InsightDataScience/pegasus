#!/bin/bash

# check input arguments
if [ "$#" -ne 1 ]; then
    echo "Please specify cluster name!" && exit 1
fi

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

CLUSTER_NAME=$1

get_cluster_publicdns_arr ${CLUSTER_NAME}

MASTER_DNS=${PUBLIC_DNS_ARR[0]}
NUM_WORKERS=${#PUBLIC_DNS_ARR[@]}

single_script="${PEG_ROOT}/config/flink/setup_single.sh"
args="$MASTER_DNS $NUM_WORKERS"

# Install and configure Flink on all nodes
for dns in "${PUBLIC_DNS_ARR[@]}"
do
  run_script_on_node ${dns} ${single_script} ${args} &
done

wait

master_script="${PEG_ROOT}/config/flink/config_master.sh"
args="$MASTER_DNS "${PUBLIC_DNS_ARR[@]:1}""
run_script_on_node ${MASTER_DNS} ${master_script} ${args}

