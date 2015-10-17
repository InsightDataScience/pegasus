#!/bin/bash

# check input arguments
if [ "$#" -ne 2 ]; then
    echo "Please specify pem-key location and cluster name" && exit 1
fi

PEMLOC=$1
INSTANCE_NAME=$2

# check if pem-key location is valid
if [ ! -f $PEMLOC ]; then
    echo "pem-key does not exist!" && exit 1
fi

if [ ! -d tmp/$INSTANCE_NAME ]; then
    echo "cluster does not exist!" && exit 1
fi

SSH/setup_passwordless_ssh.sh $PEMLOC $INSTANCE_NAME

Spark/setup_cluster.sh $PEMLOC $INSTANCE_NAME

Spark/start_spark_ipython.sh $PEMLOC $INSTANCE_NAME $(awk -F"= " 'NR==2 {print $2}' ~/.boto) $(awk -F"= " 'NR==3 {print $2}' ~/.boto)

Spark/start_spark_zeppelin.sh $PEMLOC $INSTANCE_NAME
