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
source ${PEG_ROOT}/colors.sh

CLUSTER_NAME=$1
MASTER_PUBLIC_DNS=$(fetch_cluster_master_public_dns ${CLUSTER_NAME})
PUBLIC_DNS=$(fetch_cluster_public_dns ${CLUSTER_NAME})
TECHNOLOGY="riak"
DEP_ROOT_FOLDER=/usr/local/

function check_dependencies_and_install_riak {
  if [ -z "${DEP}" ]; then
    script=${PEG_ROOT}/install/riak/install_riak.sh
    for dns in ${PUBLIC_DNS}; do
      echo -e "${color_yellow}Installing Riak on Node - ${dns} - in ${CLUSTER_NAME}${color_norm}"
      run_script_on_node ${dns} ${script} &
    done
  else
    INSTALLED=$(check_remote_folder ${MASTER_PUBLIC_DNS} ${DEP_ROOT_FOLDER}${DEP[0]})
    if [ "${INSTALLED}" = "installed" ]; then
      DEP=(${DEP[@]:1})
      check_dependencies_and_install_secor
    else
      echo "${DEP} is not installed in ${DEP_ROOT_FOLDER}"
      echo "Please install ${DEP} and then proceed with ${TECHNOLOGY}"
      echo "peg install ${CLUSTER_NAME} ${TECHNOLOGY}"
      exit 1
    fi
  fi
}

# Check if dependencies are installed
# If yes, then install riak  

DEP=($(get_dependencies))
check_dependencies_and_install_riak

wait

echo "Riak installed!"
