#!/bin/bash

# check input arguments
if [ "$#" -ne 2 ]; then
    echo "Please specify pem-key location and cluster name!" && exit 1
fi

# get input arguments
PEMLOC=$1
CLUSTER_NAME=$2

MASTER_DNS=$(head -n 1 tmp/$CLUSTER_NAME/public_dns)
ssh -i $PEMLOC ubuntu@$MASTER_DNS '. ~/.profile; $OPSCENTER_HOME/bin/opscenter'

echo "Opscenter configuration complete!"
