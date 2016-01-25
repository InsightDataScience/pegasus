#!/bin/bash

# check input arguments
if [ "$#" -ne 2 ]; then
    echo "Please specify the pem-key location and the cluster name" && exit 1
fi

PEMLOC=$1
CLUSTER_NAME=$2

echo "Pig has no service to start!"
