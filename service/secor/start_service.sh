#!/bin/bash

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

if [ "$#" -ne 1 ]; then
  echo "Please specify cluster name!" && exit 1
fi

CLUSTER_NAME=$1

MASTER_PUBLIC_DNS=$(fetch_public_dns_of_node_in_cluster ${CLUSTER_NAME} 1)
script=${PEG_ROOT}/service/secor/start_secor.sh

cmd='source ~/.profile; cd /usr/local/secor/bin; pwd; ls; sudo java -ea -Dsecor_group=secor_backup -Dlog4j.configuration=log4j.prod.properties -Dconfig=secor.prod.backup.properties -cp secor-0.21-SNAPSHOT.jar:lib/* com.pinterest.secor.main.ConsumerMain'

run_cmd_on_node ${MASTER_PUBLIC_DNS} ${cmd}

echo "Secor Started!"
