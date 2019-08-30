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

# must be called from top level

# check input arguments
if [ "$#" -ne 1 ]; then
  echo "Please specify cluster name!" && exit 1
fi

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

CLUSTER_NAME=$1

MASTER_DNS=$(fetch_cluster_master_public_dns ${CLUSTER_NAME})
WORKER_DNS=$(fetch_cluster_worker_public_dns ${CLUSTER_NAME})

HOSTNAMES=$(fetch_cluster_hostnames ${CLUSTER_NAME})

restart_sshagent_if_needed ${CLUSTER_NAME}

# Enable passwordless SSH from local to master
if ! [ -f ~/.ssh/id_rsa ]; then
  ssh-keygen -f ~/.ssh/id_rsa -t rsa -P ""
fi
cat ~/.ssh/id_rsa.pub | run_cmd_on_node ${MASTER_DNS} 'cat >> ~/.ssh/authorized_keys'

# Enable passwordless SSH from master to slaves
SCRIPT=${PEG_ROOT}/config/ssh/setup_ssh.sh
ARGS="${WORKER_DNS}"
run_script_on_node ${MASTER_DNS} ${SCRIPT} ${ARGS}

# Add NameNode, DataNodes, and Secondary NameNode to known hosts
SCRIPT=${PEG_ROOT}/config/ssh/add_to_known_hosts.sh
ARGS="${MASTER_DNS} ${HOSTNAMES}"
run_script_on_node ${MASTER_DNS} ${SCRIPT} ${ARGS}

