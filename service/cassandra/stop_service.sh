#!/bin/bash

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

# check input arguments
if [ "$#" -ne 1 ]; then
  echo "Please specify cluster name!" && exit 1
fi

CLUSTER_NAME=$1

PUBLIC_DNS=$(fetch_cluster_public_dns ${CLUSTER_NAME})

cmd='/usr/local/cassandra/bin/nodetool stopdaemon'
# Start each cassandra node
for dns in ${PUBLIC_DNS}; do
  run_cmd_on_node ${dns} ${cmd}
done

echo "Cassandra stopped!"
