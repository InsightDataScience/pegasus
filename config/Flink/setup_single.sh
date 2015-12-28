#!/bin/bash

. ~/.profile

sed -i "s@jobmanager.rpc.address: localhost@jobmanager.rip.address: '"$MASTER_IP"'@g" $FLINK_HOME/conf/flink-conf.yaml
sed -i "s@jobmanager.heap.mb: 256@jobmanager.heap.mb: '"$JOBMANAGER_HEAP"'@g" $FLINK_HOME/conf/flink-conf.yaml
sed -i "s@taskmanager.heap.mb: 512@taskmanager.heap.mb: '"$TASKMANAGER_HEAP"'@g" $FLINK_HOME/conf/flink-conf.yaml
sed -i "s@taskmanager.numberOfTaskSlots: 1@taskmanager.numberOfTaskSlots: '"$NUMTASKSLOTS"'@g" $FLINK_HOME/conf/flink-conf.yaml
sed -i "s@parallelism.default: 1@parallelism.default: '"$PARALLELISM"'@g" $FLINK_HOME/conf/flink-conf.yaml
sed -i "s@# taskmanager.tmp.dirs: /tmp@taskmanager.tmp.dirs: '"$TMP_DIRS"'@g" $FLINK_HOME/conf/flink-conf.yaml
