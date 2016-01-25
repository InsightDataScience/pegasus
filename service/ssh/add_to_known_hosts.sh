#!/bin/bash

NAMENODE_DNS=$1; shift
NAMENODE_HOSTNAME=$1; shift
DATANODE_HOSTNAMES=( "$@" )

# add NameNode to known_hosts
ssh-keyscan -H -t ecdsa $NAMENODE_DNS >> ~/.ssh/known_hosts

# add DataNodes to known_hosts
for hostname in ${DATANODE_HOSTNAMES[@]}
do
    echo "Adding $hostname to known hosts..."
    ssh-keyscan -H -t ecdsa $hostname >> ~/.ssh/known_hosts
done

# add Secondary NameNode to known_hosts
ssh-keyscan -H -t ecdsa 0.0.0.0 >> ~/.ssh/known_hosts

# add localhost and 127.0.0.1 to known_hosts
ssh-keyscan -H -t ecdsa localhost >> ~/.ssh/known_hosts
ssh-keyscan -H -t ecdsa 127.0.0.1 >> ~/.ssh/known_hosts
