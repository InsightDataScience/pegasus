#!/bin/bash

# check input arguments
if [ "$#" -ne 1 ]; then
    echo "Please specify pem-key location" && exit 1
fi

PEMLOC=$1

# check if pem-key location is valid
if [ ! -f $PEMLOC ]; then
    echo "pem-key does not exist!" && exit 1
fi

SSH/setup_passwordless_ssh.sh $PEMLOC

Spark/setup_spark_cluster.sh $PEMLOC

Spark/start_spark_ipython.sh $PEMLOC $(awk -F"= " 'NR==2 {print $2}' ~/.boto) $(awk -F"= " 'NR==3 {print $2}' ~/.boto)
