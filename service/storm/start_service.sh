#!/bin/bash

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

if [ "$#" -ne 1 ]; then
    echo "Please specify cluster name!" && exit 1
fi

CLUSTER_NAME=$1

MASTER_PUBLIC_DNS=$(get_public_dns_with_name_and_role ${CLUSTER_NAME} master)
WORKER_PUBLIC_DNS=$(get_public_dns_with_name_and_role ${CLUSTER_NAME} worker)


echo $MASTER_PUBLIC_DNS
script=${PEG_ROOT}/service/storm/start_master.sh
run_script_on_node ${MASTER_PUBLIC_DNS} ${script}

script=${PEG_ROOT}/service/storm/start_slave.sh
for dns in ${WORKER_PUBLIC_DNS}; do
  echo $dns
  run_script_on_node ${dns} ${script}
done


echo "Storm Started!"

