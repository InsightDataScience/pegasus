#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Please specify cluster name!" && exit 1
fi

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

CLUSTER_NAME=$1

get_cluster_publicdns_arr ${CLUSTER_NAME}

MASTER_DNS=${PUBLIC_DNS_ARR[0]}

single_script="${PEG_ROOT}/config/zeppelin/setup_zeppelin.sh"
run_script_on_node ${MASTER_DNS} ${single_script}

