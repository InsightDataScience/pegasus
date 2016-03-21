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

get_cluster_publicdns_arr ${CLUSTER_DNS}

cnt=0
for dns in ${NODE_DNS[@]}; do
  if [ $cnt == 0 ]; then
    ssh -i $PEMLOC ${REM_USER}@${dns} '. ~/.profile; /usr/local/alluxio/bin/alluxio-start.sh master'
  else
    ssh -i $PEMLOC ${REM_USER}@${dns} '. ~/.profile; /usr/local/alluxio/bin/alluxio-start.sh worker SudoMount'
  fi
  cnt=$(($cnt+1))
done

echo "Alluxio Started!"
