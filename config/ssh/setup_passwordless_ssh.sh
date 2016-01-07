#!/bin/bash

# must be called from top level

# check input arguments
if [ "$#" -ne 2 ]; then
    echo "Please specify pem-key location and instance name!" && exit 1
fi

# get input arguments [pem-key location]
PEMLOC=$1
INSTANCE_NAME=$2

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

# Enable passwordless SSH from local to master
if ! [ -f ~/.ssh/id_rsa ]; then
    ssh-keygen -f ~/.ssh/id_rsa -t rsa -P ""
fi
cat ~/.ssh/id_rsa.pub | ssh -o "StrictHostKeyChecking no" -i $PEMLOC ubuntu@$MASTER_DNS 'cat >> ~/.ssh/authorized_keys'

# Enable passwordless SSH from master to slaves
scp -o "StrictHostKeyChecking no" -i $PEMLOC $PEMLOC ubuntu@$MASTER_DNS:~/.ssh
ssh -i $PEMLOC ubuntu@$MASTER_DNS 'bash -s' < config/ssh/setup_ssh.sh "${SLAVE_DNS[@]}"

# Add NameNode, DataNodes, and Secondary NameNode to known hosts
ssh -i $PEMLOC ubuntu@$MASTER_DNS 'bash -s' < config/ssh/add_to_known_hosts.sh $MASTER_DNS $MASTER_NAME "${SLAVE_NAME[@]}"



