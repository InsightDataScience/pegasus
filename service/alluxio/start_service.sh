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

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

# check input arguments
if [ "$#" -ne 1 ]; then
    echo "Please specify cluster name!" && exit 1
fi

CLUSTER_NAME=$1

MASTER_DNS=$(fetch_cluster_master_public_dns ${CLUSTER_NAME})
WORKER_DNS=$(fetch_cluster_worker_public_dns ${CLUSTER_NAME})

cmd='. ~/.profile; /usr/local/alluxio/bin/alluxio-start.sh master'
run_cmd_on_node ${MASTER_DNS} ${cmd}

cmd='. ~/.profile; /usr/local/alluxio/bin/alluxio-start.sh worker SudoMount'
for dns in ${WORKER_DNS}; do
  run_cmd_on_node ${dns} ${cmd}
done

echo "Alluxio Started!"
echo -e "${color_green}Alluxio WebUI${color_norm} is running at ${color_yellow}http://${MASTER_DNS}:19999${color_norm}"
