#!/bin/bash

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

