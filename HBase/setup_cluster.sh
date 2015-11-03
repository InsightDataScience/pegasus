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

# import AWS private DNS's
HOSTIP=()
while read line; do
    HOSTIP+=($line)
done < private_dns

# import AWS public DNS's
DNS=()
while read line; do
    DNS+=($line)
done < public_dns

MASTER_DNS=$(head -n 1 ../public_dns)

# Install HBase on master and slaves
for dns in "${DNS[@]}"
do
    ssh -o "StrictHostKeyChecking no" -i $PEMLOC ubuntu@$dns 'bash -s' < HBase/setup_single.sh $MASTER_DNS "${HOSTIP[@]}" &
done

wait

ssh -i $PEMLOC ubuntu@$MASTER_DNS '/usr/local/hbase/bin/start-hbase.sh'

echo "HBase setup complete!"
