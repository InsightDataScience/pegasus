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

# import AWS public DNS's
FIRST_LINE=true
NUM_WORKERS=0
while read line; do
    if [ "$FIRST_LINE" = true ]; then
        MASTER_DNS=$line
        SLAVE_DNS=()
        FIRST_LINE=false
    else
        SLAVE_DNS+=($line)
        NUM_WORKERS=$(echo "$NUM_WORKERS + 1" | bc -l)
    fi
done < tmp/$INSTANCE_NAME/public_dns

# Install and configure Flink on all nodes
ssh -o "StrictHostKeyChecking no" -i $PEMLOC ubuntu@$MASTER_DNS 'bash -s' < config/flink/setup_single.sh $MASTER_DNS $NUM_WORKERS &
for dns in "${SLAVE_DNS[@]}"
do
    ssh -o "StrictHostKeyChecking no" -i $PEMLOC ubuntu@$dns 'bash -s' < config/flink/setup_single.sh $MASTER_DNS $NUM_WORKERS &
done

wait

ssh -i $PEMLOC ubuntu@$MASTER_DNS 'bash -s' < config/flink/config_master.sh $MASTER_DNS "${SLAVE_DNS[@]}"
ssh -i $PEMLOC ubuntu@$MASTER_DNS '/usr/local/flink/bin/start-cluster.sh'
ssh -i $PEMLOC ubuntu@$MASTER_DNS '/usr/local/flink/bin/start-webclient.sh'
