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

# import AWS private DNS names
FIRST_LINE=true
while read line; do
    if [ "$FIRST_LINE" = true ]; then
        MASTER_NAME=$line
        SLAVE_NAME=()
        FIRST_LINE=false
    else
        SLAVE_NAME+=($line)
    fi
done < tmp/$INSTANCE_NAME/private_dns

# import AWS public DNS's
FIRST_LINE=true
while read line; do
    if [ "$FIRST_LINE" = true ]; then
        MASTER_DNS=$line
        SLAVE_DNS=()
        FIRST_LINE=false
    else
        SLAVE_DNS+=($line)
    fi
done < tmp/$INSTANCE_NAME/public_dns

# Install and configure Spark on all nodes
ssh -o "StrictHostKeyChecking no" -i $PEMLOC ubuntu@$MASTER_DNS 'bash -s' < config/spark/setup_single.sh $MASTER_DNS &
for dns in "${SLAVE_DNS[@]}"
do
    ssh -o "StrictHostKeyChecking no" -i $PEMLOC ubuntu@$dns 'bash -s' < config/spark/setup_single.sh $dns &
done

wait

ssh -i $PEMLOC ubuntu@$MASTER_DNS 'bash -s' < config/spark/config_workers.sh "${SLAVE_DNS[@]}"
ssh -i $PEMLOC ubuntu@$MASTER_DNS '/usr/local/spark/sbin/start-all.sh'

ssh -i $PEMLOC ubuntu@$MASTER_DNS 'bash -s' < config/spark/setup_ipython.sh $GITHUB_USER $GITHUB_PASSWORD
