#!/bin/bash

# check input arguments
if [ "$#" -ne 1 ]; then
    echo "Please specify cluster name!" && exit 1
fi

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

CLUSTER_NAME=$1

MASTER_DNS=$(fetch_cluster_master_public_dns ${CLUSTER_NAME})

script="${PEG_ROOT}/install/memsql/install_memsql.sh"
run_script_on_node ${MASTER_DNS} ${script}

echo "Memsql installed!"
echo "Memsql Started!"
echo -e "${color_green}Memsql Cluster WebUI${color_norm} is running at ${color_yellow}http://${MASTER_DNS}:9000${color_norm}"
echo -e "Go to the WebUI to add the Leaf nodes and deploy the Memsql cluster"
