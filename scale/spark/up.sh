#!/bin/bash

if [ "$#" -ne 3 ]; then
  echo "Please specify pem-key location, cluster name, and number to scale up by!" && exit 1
fi

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
REGION=${AWS_DEFAULT_REGION:=us-west-2}
source ${PEG_ROOT}/util.sh

PEMLOC=$1
CLUSTER_NAME=$2
NUM=$3

launch_more_workers_in ${CLUSTER_NAME} ${NUM}

MASTER_DNS=$(head -n 1 ${PEG_ROOT}/tmp/${CLUSTER_NAME}/public_dns)

PUBLIC_DNS=$(get_public_dns_from_instances ${INSTANCE_IDS})
echo ${INSTANCE_IDS}
echo ${PUBLIC_DNS}

for DNS in ${PUBLIC_DNS}; do
  echo ${DNS}
  # passwordless ssh from master to worker
  ssh_script="${PEG_ROOT}/config/ssh/setup_ssh.sh"
  args="${DNS}"
  run_script_on_node ${PEMLOC} ${MASTER_DNS} ${ssh_script} ${args}

  # download spark to node
  download_script="${PEG_ROOT}/install/download_tech"
  args=spark
  run_script_on_node ${PEMLOC} ${DNS} ${download_script} ${args}

  # configure single node
  spark_single_script="${PEG_ROOT}/config/spark/setup_single.sh"
  args="${DNS}"
  run_script_on_node ${PEMLOC} ${DNS} ${spark_single_script} ${args}

  # reconfigure master
  worker_script="${PEG_ROOT}/config/spark/config_workers.sh"
  args="${DNS}"
  run_script_on_node ${PEMLOC} ${MASTER_DNS} ${worker_script} ${args}
done
