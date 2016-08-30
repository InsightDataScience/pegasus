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

# check input arguments
if [ "$#" -ne 1 ]; then
  echo "Please specify cluster name!" && exit 1
fi

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

CLUSTER_NAME=$1

PUBLIC_DNS=$(fetch_cluster_public_dns ${CLUSTER_NAME})
PRIVATE_IP_ARR=($(fetch_cluster_private_ips ${CLUSTER_NAME}))

SEED_IP=$(fetch_cluster_master_private_ip ${CLUSTER_NAME})
SEED_DNS=$(fetch_cluster_master_public_dns ${CLUSTER_NAME})

single_script="${PEG_ROOT}/config/cassandra/setup_single.sh"

IDX=0
for dns in ${PUBLIC_DNS};
do
  args="${CLUSTER_NAME} ${SEED_IP} ${PRIVATE_IP_ARR[$IDX]}"
  run_script_on_node ${dns} ${single_script} ${args} &
  IDX=$(($IDX+1))
done

wait

echo "Cassandra configuration complete!"
