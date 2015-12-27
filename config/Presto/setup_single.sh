#!/bin/bash

. ~/.profile

MASTER_DNS=$1

mkdir $PRESTO_HOME/etc
sudo mkdir -p /var/presto/data
sudo chown -R ubuntu /var/presto/data

touch $PRESTO_HOME/etc/node.properties
touch $PRESTO_HOME/etc/jvm.config
touch $PRESTO_HOME/etc/config.properties

# node.properties
node.environment=production
node.id=ffffffff-ffff-ffff-ffff-ffffffffffff
node.data-dir=/var/presto/data

# jvm.config
-server
-Xmx16G
-XX:+UseG1GC
-XX:G1HeapRegionSize=32M
-XX:+UseGCOverheadLimit
-XX:+ExplicitGCInvokesConcurrent
-XX:+HeapDumpOnOutOfMemoryError
-XX:OnOutOfMemoryError=kill -9 %p

# config.properties
http-server.http.port=8181
query.max-memory=50GB
query.max-memory-per-node=1GB
discovery.uri=http://$MASTER_DNS:8181
