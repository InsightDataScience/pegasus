#!/bin/bash

# check input arguments
if [ "$#" -ne 2 ]; then
    echo "Please specify pem-key location, and Cassandra cluster name" && exit 1
fi

PEMLOC=$1
CASSANDRA_NAME=$2

# check if pem-key location is valid
if [ ! -f $PEMLOC ]; then
    echo "pem-key does not exist!" && exit 1
fi

Cassandra/setup_cluster.sh $PEMLOC $CASSANDRA_NAME
