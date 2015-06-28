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

Kafka/setup_kafka_cluster.sh $PEMLOC
