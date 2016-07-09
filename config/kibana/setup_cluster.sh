#!/bin/bash

# check input arguments
if [ "$#" -ne 1 ]; then
    echo "Please specify cluster name!" && exit 1
fi

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

CLUSTER_NAME=$1

PUBLIC_DNS=$(fetch_public_dns_of_node_in_cluster ${CLUSTER_NAME} 1)

# Install Kibana on master
single_script="${PEG_ROOT}/config/kibana/setup_single.sh"
args="$PUBLIC_DNS"
run_script_on_node ${PUBLIC_DNS} ${single_script} ${args}

echo "Kibana configuration complete!"
