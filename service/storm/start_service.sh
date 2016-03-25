#!/bin/bash

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

if [ "$#" -ne 1 ]; then
    echo "Please specify cluster name!" && exit 1
fi

CLUSTER_NAME=$1

MASTER_DNS=$(fetch_cluster_master_public_dns ${CLUSTER_NAME})
WORKER_DNS=$(fetch_cluster_worker_public_dns ${CLUSTER_NAME})


echo $MASTER_DNS
script=${PEG_ROOT}/service/storm/start_master.sh
run_script_on_node ${MASTER_DNS} ${script}

script=${PEG_ROOT}/service/storm/start_slave.sh
for dns in ${WORKER_DNS}; do
  echo $dns
  run_script_on_node ${dns} ${script}
done


echo "Storm Started!"

