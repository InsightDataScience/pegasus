#!/bin/bash

# Copyright 2015 Insight Data Science
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# must be called from the top level

# check input arguments
if [ "$#" -ne 1 ]; then
    echo "Please specify cluster name!" && exit 1
fi

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

CLUSTER_NAME=$1

PUBLIC_DNS=$(fetch_cluster_public_dns ${CLUSTER_NAME})

MASTER_DNS=$(fetch_cluster_master_public_dns ${CLUSTER_NAME})
MASTER_HOSTNAME=$(fetch_cluster_master_hostname ${CLUSTER_NAME})

WORKER_DNS=$(fetch_cluster_worker_public_dns ${CLUSTER_NAME})
WORKER_HOSTNAMES=$(fetch_cluster_worker_hostnames ${CLUSTER_NAME})

# Configure base Hadoop master and slaves
single_script="${PEG_ROOT}/config/hadoop/setup_single.sh"
args="${MASTER_DNS} ${AWS_ACCESS_KEY_ID} ${AWS_SECRET_ACCESS_KEY}"
for dns in ${PUBLIC_DNS}; do
  run_script_on_node ${dns} ${single_script} ${args} &
done

wait

# Configure Hadoop master and slaves
hosts_script="${PEG_ROOT}/config/hadoop/config_hosts.sh"
args="${MASTER_DNS} ${MASTER_HOSTNAME} ${WORKER_DNS} ${WORKER_HOSTNAMES}"
run_script_on_node ${MASTER_DNS} ${hosts_script} ${args}

namenode_script="${PEG_ROOT}/config/hadoop/config_namenode.sh"
args="${MASTER_HOSTNAME} ${WORKER_HOSTNAMES}"
run_script_on_node ${MASTER_DNS} ${namenode_script} ${args} &

datanode_script="${PEG_ROOT}/config/hadoop/config_datanode.sh"
for dns in ${WORKER_DNS}; do
  run_script_on_node ${dns} ${datanode_script} &
done

wait

format_script="${PEG_ROOT}/config/hadoop/format_hdfs.sh"
run_script_on_node ${MASTER_DNS} ${format_script}

echo "Hadoop configuration complete!"
