#!/bin/bash

# must be called from the top level

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

WORKERS_PER_NODE=4

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

# Configure base Storm nimbus and supervisors
for dns in "${PUBLIC_DNS[@]}"
do
  ssh -o "StrictHostKeyChecking no" -i $PEMLOC ubuntu@$dns 'bash -s' < config/storm/setup_single.sh $WORKERS_PER_NODE $MASTER_DNS "${SLAVE_DNS[@]}" &
done

wait

ssh -i $PEMLOC ubuntu@$MASTER_DNS 'bash -s' < config/storm/start_master.sh

for dns in "${SLAVE_DNS[@]}"; do
  ssh -i $PEMLOC ubuntu@$dns 'bash -s' < config/storm/start_slave.sh
done


echo "Storm configuration complete!"

