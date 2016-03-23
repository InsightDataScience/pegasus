#!/bin/bash

# check input arguments
if [ "$#" -ne 1 ]; then
    echo "Please specify cluster name!" && exit 1
fi

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

CLUSTER_NAME=$1

PUBLIC_DNS=$(fetch_cluster_public_dns ${CLUSTER_NAME})

single_script="${PEG_ROOT}/config/kafka/setup_single.sh"

# Install and configure nodes for kafka
BROKER_ID=0
for dns in ${PUBLIC_DNS}; do
  args="$BROKER_ID $dns ${PUBLIC_DNS}"
  run_script_on_node ${dns} ${single_script} ${args} &
  BROKER_ID=$(($BROKER_ID+1))
done

wait

echo "Kafka configuration complete!"

