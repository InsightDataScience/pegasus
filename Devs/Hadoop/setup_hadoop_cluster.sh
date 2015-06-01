#!/bin/bash

# check input arguments
if [ "$#" -ne 1 ]; then
    echo "Please specify pem-key location!" && exit 1
fi

# get input arguments [aws region, pem-key location]
PEMLOC=$1

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
done < ../private_dns

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
done < ../public_dns

# Install Hadoop master and slaves
ssh -o "StrictHostKeyChecking no" -i $PEMLOC ubuntu@$MASTER_DNS 'bash -s' < setup_hadoop.sh $MASTER_DNS &
for dns in "${SLAVE_DNS[@]}"
do
    ssh -o "StrictHostKeyChecking no" -i $PEMLOC ubuntu@$dns 'bash -s' < setup_hadoop.sh $MASTER_DNS &
done

wait

# Configure Hadoop master and slaves
ssh -i $PEMLOC ubuntu@$MASTER_DNS 'bash -s' < setup_master_hosts.sh $MASTER_DNS $MASTER_NAME "${SLAVE_DNS[@]}" "${SLAVE_NAME[@]}"
ssh -i $PEMLOC ubuntu@$MASTER_DNS 'bash -s' < config_hadoop_master.sh $MASTER_NAME "${SLAVE_NAME[@]}" &
for dns in "${SLAVE_DNS[@]}"
do
    ssh -i $PEMLOC ubuntu@$dns 'bash -s' < config_hadoop_slave.sh &
done

wait

ssh -i $PEMLOC ubuntu@$MASTER_DNS 'bash -s' < start_hadoop.sh

echo "Hadoop setup complete!"
