#!/bin/bash

# check input arguments
if [ "$#" -ne 3 ]; then
    echo "Please specify pem-key location, DataNode Public DNS, and DataNode hostname!" && exit 1
fi

# get input arguments [aws region, pem-key location]
PEMLOC=$1
DATANODE_DNS=$2
DATANODE_HOSTNAME=$3

# check if pem-key location is valid
if [ ! -f $PEMLOC ]; then
    echo "pem-key does not exist!" && exit 1
fi

# import AWS public DNS's
MASTER_DNS=$(head -n 1 ../public_dns)

# add new DataNode for passwordless SSH
ssh -i $PEMLOC ubuntu@$MASTER_DNS 'cat ~/.ssh/id_rsa.pub | ssh -i ~/.ssh/*.pem ubuntu@'"$DATANODE_DNS"' ''cat >> ~/.ssh/authorized_keys'''

ssh -i $PEMLOC ubuntu@$MASTER_DNS 'ssh-keyscan -H -t ecdsa '"$DATANODE_HOSTNAME"' >> ~/.ssh/known_hosts'

# add DataNode as slave on NameNode
ssh -i $PEMLOC ubuntu@$MASTER_DNS 'echo '"$DATANODE_HOSTNAME"' >> /usr/local/hadoop/etc/hadoop/slaves'

# Install Hadoop datanode
ssh -o "StrictHostKeyChecking no" -i $PEMLOC ubuntu@$DATANODE_DNS 'bash -s' < setup_single.sh $MASTER_DNS

ssh -i $PEMLOC ubuntu@$DATANODE_DNS 'bash -s' < config_datanode.sh

ssh -i $PEMLOC ubuntu@$DATANODE_DNS '/usr/local/hadoop/sbin/hadoop-daemon.sh start datanode'

echo "Hadoop DataNode setup complete!"
