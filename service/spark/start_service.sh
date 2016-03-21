#!/bin/bash

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

# check input arguments
if [ "$#" -ne 1 ]; then
    echo "Please specify cluster name!" && exit 1
fi

CLUSTER_NAME=$1

MASTER_DNS=$(get_public_dns_with_name_and_role ${CLUSTER_NAME} master)

cmd='/usr/local/spark/sbin/start-all.sh'
run_cmd_on_node ${MASTER_DNS} ${cmd}

script=${PEG_ROOT}/service/spark/setup_ipython.sh
run_script_on_node ${MASTER_DNS} ${script}

echo "Spark Started!"
