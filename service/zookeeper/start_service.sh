#!/bin/bash

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

if [ "$#" -ne 1 ]; then
    echo "Please specify cluster name!" && exit 1
fi

CLUSTER_NAME=$1

get_cluster_publicdns_arr ${CLUSTER_NAME}

# Install and configure nodes for zookeeper
SERVER_NUM=1
for dns in "${PUBLIC_DNS_ARR[@]}"
do
  echo $dns
  cmd=". ~/.profile; zkServer.sh start"
  run_cmd_on_node ${dns} ${cmd} &
done

wait

echo "Zookeeper Started!"
