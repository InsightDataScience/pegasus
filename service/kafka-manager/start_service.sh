#!/bin/bash

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh
source ${PEG_ROOT}/colors.sh

if [ "$#" -ne 1 ]; then
  echo "Please specify cluster name!" && exit 1
fi

CLUSTER_NAME=$1

MASTER_PUBLIC_DNS=$(fetch_public_dns_of_node_in_cluster ${CLUSTER_NAME} 1)

cmd='source ~/.profile; $KAFKA_MANAGER_HOME/bin/kafka-manager -Dhttp.port=9001 &'

run_cmd_on_node ${MASTER_PUBLIC_DNS} ${cmd} &

echo "kafka-manager started!"
echo -e "${color_yellow}Kafka Manager UI running on: http://${MASTER_PUBLIC_DNS}:9001${color_norm}"
