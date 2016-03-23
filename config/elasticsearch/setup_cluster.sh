#!/bin/bash

# check input arguments
if [ "$#" -ne 1 ]; then
    echo "Please specify cluster name!" && exit 1
fi

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

CLUSTER_NAME=$1

PUBLIC_DNS=$(fetch_cluster_public_dns ${CLUSTER_NAME})

single_script="${PEG_ROOT}/config/elasticsearch/setup_single.sh"
args="$CLUSTER_NAME $REGION $AWS_SECRET_ACCESS_KEY $AWS_ACCESS_KEY_ID"
# Install and configure nodes for elasticsearch
for dns in ${PUBLIC_DNS}; do
  run_script_on_node ${dns} ${single_script} ${args} &
done

wait

echo "Elasticsearch configuration complete!"

