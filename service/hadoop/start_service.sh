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

if [ "$#" -ne 1 ]; then
    echo "Please specify cluster name!" && exit 1
fi

CLUSTER_NAME=$1

MASTER_DNS=$(fetch_cluster_master_public_dns ${CLUSTER_NAME})

run_cmd_on_node ${MASTER_DNS} '. ~/.profile; $HADOOP_HOME/sbin/start-dfs.sh'
run_cmd_on_node ${MASTER_DNS} '. ~/.profile; $HADOOP_HOME/sbin/start-yarn.sh'
run_cmd_on_node ${MASTER_DNS} '. ~/.profile; $HADOOP_HOME/sbin/mr-jobhistory-daemon.sh start historyserver'

echo "Hadoop started!"
echo -e "${color_green}HDFS WebUI${color_norm} is running at ${color_yellow}http://${MASTER_DNS}:50070${color_norm}"
echo -e "${color_green}Hadoop Job Tracker WebUI${color_norm} is running at ${color_yellow}http://${MASTER_DNS}:8088${color_norm}"
echo -e "${color_green}Hadoop Job History WebUI${color_norm} is running at ${color_yellow}http://${MASTER_DNS}:19888${color_norm}"

