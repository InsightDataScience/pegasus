#!/bin/bash

# check input arguments
if [ "$#" -ne 1 ]; then
    echo "Please specify cluster name!" && exit 1
fi

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

CLUSTER_NAME=$1

MASTER_DNS=$(get_public_dns_with_name_and_role ${CLUSTER_NAME} master)

# Install Kibana on master
single_script="${PEG_ROOT}/config/kibana/setup_single.sh"
args="$MASTER_DNS"
run_script_on_node ${MASTER_DNS} ${single_script} ${args}

echo "Kibana configuration complete!"
