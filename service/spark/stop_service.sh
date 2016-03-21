#!/bin/bash

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

# check input arguments
if [ "$#" -ne 1 ]; then
    echo "Please specify cluster name!" && exit 1
fi

CLUSTER_NAME=$1

MASTER_DNS=$(get_public_dns_with_name_and_role ${CLUSTER_NAME} master)

cmd='tmux kill-session -t ipython_notebook'
run_cmd_on_node ${MASTER_DNS} ${cmd}

cmd='/usr/local/spark/sbin/stop-all.sh'
run_cmd_on_node ${MASTER_DNS} ${cmd}

echo "Spark Stopped!"
