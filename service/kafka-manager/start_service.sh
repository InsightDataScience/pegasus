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
source ${PEG_ROOT}/colors.sh

if [ "$#" -ne 1 ]; then
  echo "Please specify cluster name!" && exit 1
fi

CLUSTER_NAME=$1

MASTER_PUBLIC_DNS=$(fetch_public_dns_of_node_in_cluster ${CLUSTER_NAME} 1)

cmd='source ~/.profile; $KAFKA_MANAGER_HOME/bin/kafka-manager -Dhttp.port=9001 &'

run_cmd_on_node ${MASTER_PUBLIC_DNS} ${cmd} &

echo "kafka-manager started!"
echo -e "${color_yellow}Kafka Manager UI running on: http://${MASTER_PUBLIC_DNS}:9001${color_norm}"
