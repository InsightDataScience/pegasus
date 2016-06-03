#!/bin/bash

if [ "$#" -ne 1 ]; then
    echo "Please specify cluster name!" && exit 1
fi

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh
source ${PEG_ROOT}/colors.sh

CLUSTER_NAME=$1

PUBLIC_DNS=$(fetch_cluster_public_dns ${CLUSTER_NAME})
MASTER_PUBLIC_DNS=$(fetch_public_dns_of_node_in_cluster ${CLUSTER_NAME} 1)

single_script="${PEG_ROOT}/config/kafka-manager/setup_kafka_manager.sh"
args="${PUBLIC_DNS}"
run_script_on_node ${MASTER_PUBLIC_DNS} ${single_script} ${args} &

wait 

echo -e "${color_green}Kafka-manager configuration complete on ${MASTER_PUBLIC_DNS}!${color_norm}" 
