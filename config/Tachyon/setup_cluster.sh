#!/bin/bash

# must be called from the top level

# check input arguments
if [ "$#" -ne 2 ]; then
    echo "Please specify pem-key location!" && exit 1
fi

# get input arguments [aws region, pem-key location]
PEMLOC=$1
INSTANCE_NAME=$2

# check if pem-key location is valid
if [ ! -f $PEMLOC ]; then
    echo "pem-key does not exist!" && exit 1
fi

# import AWS private DNS names
NODE_NAME=()
while read line; do
    NODE_NAME+=($line)
done < tmp/$INSTANCE_NAME/private_dns

# import AWS public DNS's
NODE_DNS=()
while read line; do
    NODE_DNS+=($line)
done < tmp/$INSTANCE_NAME/public_dns

# Install Tachyon on master and slaves
for dns in "${NODE_DNS[@]}"
do
    ssh -o "StrictHostKeyChecking no" -i $PEMLOC ubuntu@$dns 'bash -s' < config/tachyon/setup_single.sh "${NODE_NAME[@]}" &
done

wait

ssh -i $PEMLOC ubuntu@${NODE_DNS[0]} '/usr/local/tachyon/bin/tachyon format'
ssh -i $PEMLOC ubuntu@${NODE_DNS[0]} '/usr/local/tachyon/bin/tachyon-start.sh all SudoMount'

echo "Tachyon configuration complete!"
