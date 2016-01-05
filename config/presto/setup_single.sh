#!/bin/bash

. ~/.profile

MASTER_DNS=$1
NUM_WORKERS=$2

MEMINFO=($(free -m | sed -n '2p' | sed -e "s/[[:space:]]\+/ /g"))
TOTMEM=${MEMINFO[1]}
MAX_MEMORY_PER_NODE=$(printf "%.0f" $(echo "0.90 * ($TOTMEM - 6000) * 0.001" | bc -l))

MAX_MEMORY=$(echo "$MAX_MEMORY_PER_NODE * $NUM_WORKERS" | bc -l)

PORT=8080

mkdir $PRESTO_HOME/etc

DATA_PATH=/var/presto/data
sudo mkdir -p $DATA_PATH
sudo chown -R ubuntu $DATA_PATH

NODE_PROPERTIES_PATH=$PRESTO_HOME/etc/node.properties
JVM_CONFIG_PATH=$PRESTO_HOME/etc/jvm.config
CONFIG_PROPERTIES_PATH=$PRESTO_HOME/etc/config.properties
LOG_PROPERTIES_PATH=$PRESTO_HOME/etc/log.properties

mkdir $PRESTO_HOME/etc/catalog

touch $NODE_PROPERTIES_PATH
touch $JVM_CONFIG_PATH
touch $CONFIG_PROPERTIES_PATH
touch $LOG_PROPERTIES_PATH

# node.properties
cat >> $NODE_PROPERTIES_PATH << EOL
node.environment=production
node.id=$(uuidgen)
node.data-dir=${DATA_PATH}
EOL

# jvm.config
cat >> $JVM_CONFIG_PATH << EOL
-server
-Xmx16G
-XX:+UseConcMarkSweepGC
-XX:+ExplicitGCInvokesConcurrent
-XX:+CMSClassUnloadingEnabled
-XX:+AggressiveOpts
-XX:+HeapDumpOnOutOfMemoryError
-XX:OnOutOfMemoryError=kill -9 %p
-XX:PermSize=150M
-XX:MaxPermSize=150M
-XX:ReservedCodeCacheSize=150M
-Xbootclasspath/p:/var/presto/installation/lib/floatingdecimal-0.2.jar
EOL

# config.properties
cat >> $CONFIG_PROPERTIES_PATH << EOL
http-server.http.port=${PORT}
task.max-memory=${MAX_MEMORY}GB
discovery.uri=http://${MASTER_DNS}:${PORT}
EOL

# log.properties
cat >> $LOG_PROPERTIES_PATH << EOL
com.facebook.presto=WARN
EOL

echo "connector.name=jmx" > $PRESTO_HOME/etc/catalog/jmx.properties
