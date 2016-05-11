#!/bin/bash

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

if [ "$#" -ne 1 ]; then
    echo "Please specify cluster name!" && exit 1
fi

CLUSTER_NAME=$1

PUBLIC_DNS=$(fetch_cluster_public_dns ${CLUSTER_NAME})

# Install and configure nodes for zookeeper
for dns in ${PUBLIC_DNS}; do
  echo $dns
  cmd=". ~/.profile; zkServer.sh start"
  run_cmd_on_node ${dns} ${cmd} &
done

wait

echo "Zookeeper Started!"
