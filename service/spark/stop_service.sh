#!/bin/bash

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..

# check input arguments
if [ "$#" -ne 2 ]; then
    echo "Please specify pem-key location and cluster name!" && exit 1
fi

# get input arguments [aws region, pem-key location]
PEMLOC=$1
INSTANCE_NAME=$2

# check if pem-key location is valid
if [ ! -f $PEMLOC ]; then
    echo "pem-key does not exist!" && exit 1
fi

MASTER_DNS=$(head -n 1 ${PEG_ROOT}/tmp/${INSTANCE_NAME}/public_dns)

ssh -i $PEMLOC ubuntu@$MASTER_DNS 'tmux kill-session -t ipython_notebook'
ssh -i $PEMLOC ubuntu@$MASTER_DNS '/usr/local/spark/sbin/stop-all.sh'

echo "Spark Stopped!"
