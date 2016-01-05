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
SEED_IP=$(head -n 1 tmp/$INSTANCE_NAME/private_dns | tr - . | cut -b 4-)
NODE_IP=()
while read line; do
    IP=$(echo $line | tr - . | cut -b 4-)
    NODE_IP+=($IP)
done < tmp/$INSTANCE_NAME/private_dns


# import AWS public DNS's
SEED_DNS=$(head -n 1 tmp/$INSTANCE_NAME/public_dns)
NODE_DNS=()
while read line; do
    NODE_DNS+=($line)
done < tmp/$INSTANCE_NAME/public_dns

# Install and configure nodes for cassandra
IP_CNT=0
for dns in "${NODE_DNS[@]}";
do
    ssh -o "StrictHostKeyChecking no" -i $PEMLOC ubuntu@$dns 'bash -s' < config/cassandra/setup_single.sh $INSTANCE_NAME $SEED_IP ${NODE_IP[$IP_CNT]} & 
    IP_CNT=$(echo "$IP_CNT+1" | bc)
done
wait

# Start each cassandra node
for dns in "${NODE_DNS[@]}";
do
    ssh -i $PEMLOC ubuntu@$dns '/usr/local/cassandra/bin/cassandra'
done

echo "Cassandra configuration complete!"
