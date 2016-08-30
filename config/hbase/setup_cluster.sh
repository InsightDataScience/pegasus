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

HOSTNAMES=$(fetch_cluster_hostnames ${CLUSTER_NAME})
PUBLIC_DNS=$(fetch_cluster_public_dns ${CLUSTER_NAME})

MASTER_DNS=$(fetch_cluster_master_public_dns ${CLUSTER_NAME})

# Install HBase on master and slaves
single_script="${PEG_ROOT}/config/hbase/setup_single.sh"
args="$MASTER_DNS ${HOSTNAMES}"
for dns in ${PUBLIC_DNS}; do
  run_script_on_node ${dns} ${single_script} ${args} &
done

wait

echo "HBase configuration complete!"
