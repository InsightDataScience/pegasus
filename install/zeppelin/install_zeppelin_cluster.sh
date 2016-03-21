#!/bin/bash

# check input arguments
if [ "$#" -ne 1 ]; then
    echo "Please specify cluster name!" && exit 1
fi

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

# get input arguments [aws region, pem-key location]
CLUSTER_NAME=$1

MASTER_PUBLIC_DNS=$(get_public_dns_with_name_and_role ${CLUSTER_NAME} master)

# Install Zeppelin
script=${PEG_ROOT}/install/zeppelin/install_zeppelin.sh
run_script_on_node ${MASTER_PUBLIC_DNS} ${script}

echo "Zeppelin installed!"
