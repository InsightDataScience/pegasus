#!/bin/bash

# must be called from top level

# check input arguments
if [ "$#" -ne 2 ]; then
    echo "Please specify pem-key location and instance name!" && exit 1
fi

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

# get input arguments [pem-key location]
PEMLOC=$1
CLUSTER_NAME=$2

MASTER_DNS=$(get_public_dns_with_name_and_role ${CLUSTER_NAME} master)
SLAVE_DNS=($(get_public_dns_with_name_and_role ${CLUSTER_NAME} worker))
MASTER_NAME=$(get_hostnames_with_name_and_role ${CLUSTER_NAME} master)
SLAVE_NAME=($(get_hostnames_with_name_and_role ${CLUSTER_NAME} worker))

# Enable passwordless SSH from local to master
if ! [ -f ~/.ssh/id_rsa ]; then
    ssh-keygen -f ~/.ssh/id_rsa -t rsa -P ""
fi
cat ~/.ssh/id_rsa.pub | ssh -o "StrictHostKeyChecking no" -i $PEMLOC ${REM_USER}@$MASTER_DNS 'cat >> ~/.ssh/authorized_keys'

# Enable passwordless SSH from master to slaves
scp -o "StrictHostKeyChecking no" -i $PEMLOC $PEMLOC ${REM_USER}@$MASTER_DNS:~/.ssh
ssh -i $PEMLOC ${REM_USER}@$MASTER_DNS 'bash -s' < ${PEG_ROOT}/config/ssh/setup_ssh.sh "${SLAVE_DNS[@]}"

# Add NameNode, DataNodes, and Secondary NameNode to known hosts
ssh -i $PEMLOC ${REM_USER}@$MASTER_DNS 'bash -s' < ${PEG_ROOT}/config/ssh/add_to_known_hosts.sh $MASTER_DNS $MASTER_NAME "${SLAVE_NAME[@]}"
