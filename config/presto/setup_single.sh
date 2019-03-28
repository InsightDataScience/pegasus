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

. ~/.profile

MASTER_DNS=$1
NUM_WORKERS=$2

MEMINFO=($(free -m | sed -n '2p' | sed -e "s/[[:space:]]\+/ /g"))
TOTMEM=${MEMINFO[1]}
MAX_MEMORY_PER_NODE=$(printf "%.0f" $(echo "0.90 * ( $TOTMEM - 6000 ) * 0.001" | awk '{print $1 * ($4-$6) * $8}'))

MAX_MEMORY=$(echo "$MAX_MEMORY_PER_NODE * $NUM_WORKERS" | awk '{$1 * $3}')

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
