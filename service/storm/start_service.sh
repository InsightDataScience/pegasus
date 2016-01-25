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

ssh -i $PEMLOC ubuntu@$MASTER_DNS 'bash -s' < service/storm/start_master.sh

for dns in "${SLAVE_DNS[@]}"; do
  ssh -i $PEMLOC ubuntu@$dns 'bash -s' < service/storm/start_slave.sh
done


echo "Storm Started!"

