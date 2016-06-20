#!/bin/bash

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

if [ "$#" -ne 1 ]; then
    echo "Please specify cluster name!" && exit 1
fi

CLUSTER_NAME=$1

MASTER_DNS=$(fetch_cluster_master_public_dns ${CLUSTER_NAME})

run_cmd_on_node ${MASTER_DNS} '/usr/local/flink/bin/start-cluster.sh'

echo "Flink Started!"
echo -e "${color_green}Flink WebUI${color_norm} is running at ${color_yellow}http://${MASTER_DNS}:8081${color_norm}"
