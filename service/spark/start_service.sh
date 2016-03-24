#!/bin/bash

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

# check input arguments
if [ "$#" -ne 1 ]; then
    echo "Please specify cluster name!" && exit 1
fi

CLUSTER_NAME=$1

MASTER_DNS=$(fetch_cluster_master_public_dns ${CLUSTER_NAME})

cmd='/usr/local/spark/sbin/start-all.sh'
run_cmd_on_node ${MASTER_DNS} ${cmd}

script=${PEG_ROOT}/service/spark/setup_ipython.sh
run_script_on_node ${MASTER_DNS} ${script}

echo "Spark Started!"
echo -e "${color_green}Spark Cluster WebUI${color_norm} is running at ${color_yellow}http://${MASTER_DNS}:8080${color_norm}"
echo -e "${color_green}Spark Job WebUI${color_norm} is running at ${color_yellow}http://${MASTER_DNS}:4040${color_norm}"
echo -e "${color_green}Spark Jupyter Notebook${color_norm} is running at ${color_yellow}http://${MASTER_DNS}:7777${color_norm}"
