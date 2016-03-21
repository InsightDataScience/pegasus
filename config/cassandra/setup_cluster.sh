#!/bin/bash

# check input arguments
if [ "$#" -ne 1 ]; then
  echo "Please specify cluster name!" && exit 1
fi

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

CLUSTER_NAME=$1

get_cluster_privateip_arr ${CLUSTER_NAME}
get_cluster_publicdns_arr ${CLUSTER_NAME}

SEED_IP=${PRIVATE_IP_ARR[0]}
SEED_DNS=${PUBLIC_DNS_ARR[0]}

single_script="${PEG_ROOT}/config/cassandra/setup_single.sh"

IDX=0
for dns in "${PUBLIC_DNS_ARR[@]}";
do
  args="${CLUSTER_NAME} ${SEED_IP} ${PRIVATE_IP_ARR[$IDX]}"
  run_script_on_node ${dns} ${single_script} ${args} &
  IDX=$(($IDX+1))
done

wait

echo "Cassandra configuration complete!"
