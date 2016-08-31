#!/bin/bash

# Copyright 2015 Insight Data Science
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

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

