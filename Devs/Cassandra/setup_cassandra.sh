#!/bin/bash

CLUSTER=$1
SEED_PRIVATE_IP=$2
NODE_PRIVATE_IP=$3

sudo apt-get update
sudo apt-get --yes --force-yes install openjdk-7-jdk

mkdir ~/Downloads

curl -L http://downloads.datastax.com/community/dsc.tar.gz | tar xz -C ~/Downloads

sudo mv ~/Downloads/dsc-cassandra-* /usr/local/cassandra

echo -e "\nexport CASSANDRA_HOME=/usr/local/cassandra\nexport PATH=\$PATH:\$CASSANDRA_HOME/bin" > ~/.profile

. ~/.profile

sed -i "s@cluster_name: 'Test Cluster'@cluster_name: '"$CLUSTER"'@g" $CASSANDRA_HOME/conf/cassandra.yaml
sed -i 's@- seeds: "127.0.0.1"@- seeds: "'"$SEED_PRIVATE_IP"'"@g' $CASSANDRA_HOME/conf/cassandra.yaml
sed -i 's@listen_address: localhost@listen_address: '"$NODE_PRIVATE_IP"'@g' $CASSANDRA_HOME/conf/cassandra.yaml
sed -i 's@rpc_address: localhost@rpc_address: 0.0.0.0@g' $CASSANDRA_HOME/conf/cassandra.yaml
sed -i 's@\# broadcast_rpc_address: 1.2.3.4@broadcast_rpc_address: '"$NODE_PRIVATE_IP"'@g' $CASSANDRA_HOME/conf/cassandra.yaml
sed -i 's@endpoint_snitch: SimpleSnitch@endpoint_snitch: Ec2Snitch@g' $CASSANDRA_HOME/conf/cassandra.yaml

cassandra
