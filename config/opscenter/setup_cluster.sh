#!/bin/bash

# check input arguments
if [ "$#" -ne 2 ]; then
    echo "Please specify pem-key location and cluster name!" && exit 1
fi

# get input arguments
PEMLOC=$1
CLUSTER_NAME=$2

echo "Opscenter has no configurations!"
