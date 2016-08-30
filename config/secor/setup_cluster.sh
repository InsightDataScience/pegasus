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

if [ "$#" -ne 1 ]; then
    echo "Please specify cluster name!" && exit 1
fi

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh
source ${PEG_ROOT}/colors.sh

CLUSTER_NAME=$1

PUBLIC_DNS=$(fetch_cluster_public_dns ${CLUSTER_NAME})
MASTER_PUBLIC_DNS=$(fetch_public_dns_of_node_in_cluster ${CLUSTER_NAME} 1)

echo -e "${color_magenta}"

while [ -z ${s3_bucket} ]; do
  read -p "Which S3 bucket do you want to use? " s3_bucket
done

echo -e "${color_norm}"

single_script="${PEG_ROOT}/config/secor/setup_secor.sh"
args="${PUBLIC_DNS} ${s3_bucket}"
run_script_on_node ${MASTER_PUBLIC_DNS} ${single_script} ${args} &

wait 

echo -e "${color_green}Secor configuration complete on ${MASTER_PUBLIC_DNS}!${color_norm}" 
