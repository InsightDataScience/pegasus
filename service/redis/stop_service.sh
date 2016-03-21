#!/bin/bash

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

if [ "$#" -ne 1 ]; then
  echo "Please specify cluster name!" && exit 1
fi

CLUSTER_NAME=$1

get_cluster_publicdns_arr ${CLUSTER_NAME}

# Install and configure nodes for redis
cmd='/usr/local/redis/src/redis-cli shutdown'
for dns in "${PUBLIC_DNS_ARR[@]}"; do
  run_cmd_on_node ${dns} ${cmd} &
done

wait

echo "Redis Stopped!"
