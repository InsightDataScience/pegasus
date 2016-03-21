#!/bin/bash

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

# check input arguments
if [ "$#" -ne 2 ]; then
    echo "Please specify pem-key location!" && exit 1
fi

# get input arguments [aws region, pem-key location]
PEMLOC=$1
CLUSTER_NAME=$2

# check if pem-key location is valid
if [ ! -f $PEMLOC ]; then
    echo "pem-key does not exist!" && exit 1
fi

MASTER_DNS=$(get_public_dns_with_name_and_role ${CLUSTER_NAME} master)

ssh -i $PEMLOC ${REM_USER}@${MASTER_DNS} '/usr/local/tachyon/bin/tachyon-stop.sh'

echo "Tachyon Stopped!"
