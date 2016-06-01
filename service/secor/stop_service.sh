#!/bin/bash

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

if [ "$#" -ne 1 ]; then
  echo "Please specify cluster name!" && exit 1
fi

CLUSTER_NAME=$1

MASTER_PUBLIC_DNS=$(fetch_public_dns_of_node_in_cluster ${CLUSTER_NAME} 1)

cmd="sudo kill -9 $(ps aux | grep '[s]ecor' | awk '{print $2}')"

run_cmd_on_node ${MASTER_PUBLIC_DNS} ${cmd}

echo "Secor Stopped!"
