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

MASTER_IP=$1
NUM_WORKERS=$2

MEMINFO=($(free -m | sed -n '2p' | sed -e "s/[[:space:]]\+/ /g"))
TOTMEM=${MEMINFO[1]}
TASKMANAGER_HEAP=$(printf "%.0f" $(echo "0.90 * ($TOTMEM - 1000)" | bc -l))
TASK_SLOTS=$(nproc)
PARALLELISM=$(echo "$TASK_SLOTS * $NUM_WORKERS" | bc -l)
TMP_DIRS=/var/flink/tmp

sudo mkdir -p $TMP_DIRS
sudo chown -R ubuntu $TMP_DIRS

cp ${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-*.jar ${FLINK_HOME}/lib
cp ${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-aws-*.jar ${FLINK_HOME}/lib
cp ${HADOOP_HOME}/share/hadoop/tools/lib/httpclient-*.jar ${FLINK_HOME}/lib
cp ${HADOOP_HOME}/share/hadoop/tools/lib/httpcore-*.jar ${FLINK_HOME}/lib

sed -i "s@jobmanager.rpc.address: localhost@jobmanager.rpc.address: $MASTER_IP@g" $FLINK_HOME/conf/flink-conf.yaml
sed -i "s@jobmanager.heap.mb: 256@jobmanager.heap.mb: 1024@g" $FLINK_HOME/conf/flink-conf.yaml
sed -i "s@taskmanager.heap.mb: 512@taskmanager.heap.mb: $TASKMANAGER_HEAP@g" $FLINK_HOME/conf/flink-conf.yaml
sed -i "s@taskmanager.numberOfTaskSlots: 1@taskmanager.numberOfTaskSlots: $TASK_SLOTS@g" $FLINK_HOME/conf/flink-conf.yaml
sed -i "s@parallelism.default: 1@parallelism.default: $PARALLELISM@g" $FLINK_HOME/conf/flink-conf.yaml
sed -i "s@# taskmanager.tmp.dirs: /tmp@taskmanager.tmp.dirs: $TMP_DIRS@g" $FLINK_HOME/conf/flink-conf.yaml
sed -i "s@# fs.hdfs.hadoopconf: /path/to/hadoop/conf/@fs.hdfs.hadoopconf: $HADOOP_HOME/etc/hadoop@g" $FLINK_HOME/conf/flink-conf.yaml
