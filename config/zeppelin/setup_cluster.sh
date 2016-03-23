#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Please specify cluster name!" && exit 1
fi

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

CLUSTER_NAME=$1

MASTER_DNS=$(fetch_cluster_master_public_dns ${CLUSTER_NAME})

single_script="${PEG_ROOT}/config/zeppelin/setup_zeppelin.sh"
run_script_on_node ${MASTER_DNS} ${single_script}

