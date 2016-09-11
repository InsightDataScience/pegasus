#!/bin/bash

# check input arguments
if [ "$#" -ne 1 ]; then
    echo "Please specify cluster name!" && exit 1
fi

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh
source ${PEG_ROOT}/colors.sh

CLUSTER_NAME=$1
MASTER_PUBLIC_DNS=$(fetch_public_dns_of_node_in_cluster ${CLUSTER_NAME} 1)
TECHNOLOGY="kibana"
DEP_ROOT_FOLDER=/usr/local/

function check_dependencies_and_install_kibana {
  if [ -z "${DEP}" ]; then
    echo -e "${color_yellow}Installing Kibana on Node - ${MASTER_PUBLIC_DNS} - in ${CLUSTER_NAME}${color_norm}"
    script=${PEG_ROOT}/install/secor/install_kibana.sh
    run_script_on_node ${MASTER_PUBLIC_DNS} ${script}
  else
    INSTALLED=$(check_remote_folder ${MASTER_PUBLIC_DNS} ${DEP_ROOT_FOLDER}${DEP[0]})
    if [ "${INSTALLED}" = "installed" ]; then
      DEP=(${DEP[@]:1})
      check_dependencies_and_install_kibana
    else
      echo "${DEP} is not installed in ${DEP_ROOT_FOLDER}"
      echo "Please install ${DEP} and then proceed with ${TECHNOLOGY}"
      echo "peg install ${CLUSTER_NAME} ${TECHNOLOGY}"
      exit 1
    fi
  fi
}

# Check if dependencies are installed
# If yes, then install secor  
DEP=($(get_dependencies))
check_dependencies_and_install_kibana

echo "Kibana installed!"
