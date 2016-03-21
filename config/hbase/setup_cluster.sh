#!/bin/bash

# check input arguments
if [ "$#" -ne 1 ]; then
    echo "Please specify cluster name!" && exit 1
fi

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

CLUSTER_NAME=$1

get_cluster_hostname_arr ${CLUSTER_NAME}
get_cluster_publicdns_arr ${CLUSTER_NAME}

MASTER_DNS=${PUBLIC_DNS_ARR[0]}

# Install HBase on master and slaves
single_script="${PEG_ROOT}/config/hbase/setup_single.sh"
args="$MASTER_DNS "${HOSTNAME_ARR[@]}""
for dns in "${PUBLIC_DNS_ARR[@]}"
do
  run_script_on_node ${dns} ${single_script} ${args} &
done

wait

echo "HBase configuration complete!"
