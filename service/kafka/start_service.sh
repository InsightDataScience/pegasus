#!/bin/bash

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

if [ "$#" -ne 1 ]; then
    echo "Please specify cluster name!" && exit 1
fi

CLUSTER_NAME=$1

get_cluster_publicdns_arr ${CLUSTER_NAME}

cmd='sudo /usr/local/kafka/bin/kafka-server-start.sh /usr/local/kafka/config/server.properties &'
# Start kafka broker on all nodes
for dns in "${PUBLIC_DNS_ARR[@]}"
do
  echo $dns
  run_cmd_on_node ${dns} ${cmd} &
done

wait

echo "Kafka Started!"

