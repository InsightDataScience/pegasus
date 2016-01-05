#!/bin/bash

CLUSTER=$1
SEED_PRIVATE_IP=$2
NODE_PRIVATE_IP=$3

. ~/.profile

sed -i "s@cluster_name: 'Test Cluster'@cluster_name: '"$CLUSTER"'@g" $CASSANDRA_HOME/conf/cassandra.yaml
sed -i 's@- seeds: "127.0.0.1"@- seeds: "'"$SEED_PRIVATE_IP"'"@g' $CASSANDRA_HOME/conf/cassandra.yaml
sed -i 's@listen_address: localhost@listen_address: '"$NODE_PRIVATE_IP"'@g' $CASSANDRA_HOME/conf/cassandra.yaml
sed -i 's@rpc_address: localhost@rpc_address: 0.0.0.0@g' $CASSANDRA_HOME/conf/cassandra.yaml
sed -i 's@\# broadcast_rpc_address: 1.2.3.4@broadcast_rpc_address: '"$NODE_PRIVATE_IP"'@g' $CASSANDRA_HOME/conf/cassandra.yaml
sed -i 's@endpoint_snitch: SimpleSnitch@endpoint_snitch: Ec2Snitch@g' $CASSANDRA_HOME/conf/cassandra.yaml

