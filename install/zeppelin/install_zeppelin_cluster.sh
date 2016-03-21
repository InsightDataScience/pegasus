#!/bin/bash

# must be called from the top level

# check input arguments
if [ "$#" -ne 2 ]; then
    echo "Please specify pem-key location and cluster name!" && exit 1
fi

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

# get input arguments [aws region, pem-key location]
PEMLOC=$1
CLUSTER_NAME=$2

# check if pem-key location is valid
if [ ! -f $PEMLOC ]; then
    echo "pem-key does not exist!" && exit 1
fi

MASTER_PUBLIC_DNS=$(get_public_dns_with_name_and_role ${CLUSTER_NAME} master)

# Install Zeppelin
script=${PEG_ROOT}/install/zeppelin/install_zeppelin.sh
run_script_on_node ${PEMLOC} ${MASTER_PUBLIC_DNS} ${script}

echo "Zeppelin installed!"
