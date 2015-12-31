#!/bin/bash

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

MASTER_DNS=$(head -n 1 tmp/$INSTANCE_NAME/public_dns)

# Install Kibana on master
ssh -o "StrictHostKeyChecking no" -i $PEMLOC ubuntu@$MASTER_DNS 'bash -s' < config/kibana/setup_single.sh $MASTER_DNS

ssh -i $PEMLOC ubuntu@$MASTER_DNS '. ~/.profile; sudo $KIBANA_HOME/bin/kibana &'

echo "Kibana configuration complete!"
