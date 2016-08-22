#!/bin/bash

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

# check input arguments
if [ "$#" -ne 1 ]; then
    echo "Please specify cluster name!" && exit 1
fi

CLUSTER_NAME=$1

MASTER_DNS=$(fetch_cluster_master_public_dns ${CLUSTER_NAME})

cmd='. ~/.profile; sudo memsql-ops agent-start --all'
run_cmd_on_node ${MASTER_DNS} ${cmd}

echo "Memsql Started!"
echo -e "${color_green}Memsql WebUI${color_norm} is running at ${color_yellow}http://${MASTER_DNS}:9000${color_norm}"

