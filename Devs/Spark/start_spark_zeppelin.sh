#!/bin/bash

# check input arguments
if [ "$#" -ne 2 ]; then
    echo "Please specify pem-key location and cluster name!" && exit 1
fi

PEMLOC=$1
INSTANCE_NAME=$2
MASTER_NAME=$(sed -n 1p tmp/$INSTANCE_NAME/private_dns)

ssh -o "StrictHostKeyChecking no" -i $PEMLOC ubuntu@$(head -n 1 tmp/$INSTANCE_NAME/public_dns) 'bash -s' < Spark/setup_zeppelin.sh $MASTER_NAME

sleep 3

TCP_PID=$(lsof -i tcp:7888 | awk '{print $2}' | sed -n 2p)
kill $TCP_PID

ssh -N -f -L localhost:7888:localhost:7888 ubuntu@$(head -n 1 tmp/$INSTANCE_NAME/public_dns)

echo "Zeppelin server is running at localhost:7888!"

