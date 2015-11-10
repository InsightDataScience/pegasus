#!/bin/bash

MASTER_NAME=$1; shift
ZK_HOSTNAME=( "$@" )

. ~/.profile

# configure hbase-site.xml
sudo sed -i '24i <property>\n  <name>hbase.rootdir</name>\n  <value>hdfs://'"$MASTER_NAME"':9000/hbase</value>\n</property>' $HBASE_HOME/conf/hbase-site.xml

sudo sed -i '24i <property>\n  <name>hbase.zookeeper.property.dataDir</name>\n  <value>/var/lib/zookeeper</value>\n</property>' $HBASE_HOME/conf/hbase-site.xml

sudo sed -i '24i <property>\n  <name>hbase.cluster.distributed</name>\n  <value>true</value>\n</property>' $HBASE_HOME/conf/hbase-site.xml

ZK_QUORUM=""
for ZK in ${ZK_HOSTNAME[@]}; do
    ZK_QUORUM+=$ZK,
done
ZK_QUORUM=${ZK_QUORUM%?}

sudo sed -i '24i <property>\n  <name>hbase.zookeeper.quorum</name>\n  <value>'"$ZK_QUORUM"'</value>\n</property>' $HBASE_HOME/conf/hbase-site.xml

# configure hbase-env.sh
sudo sed -i 's@# export HBASE_MANAGES_ZK=true@export HBASE_MANAGES_ZK=false@g' $HBASE_HOME/conf/hbase-env.sh

sudo sed -i 's@# export JAVA_HOME=/usr/java/jdk1.6.0/@export JAVA_HOME=/usr@g' $HBASE_HOME/conf/hbase-env.sh

# setup RegionServers on all nodes except the first one
REGIONSERVERS=( ${ZK_HOSTNAME[@]:1} )
sudo mv $HBASE_HOME/conf/regionservers $HBASE_HOME/conf/regionservers.backup

for RS in ${REGIONSERVERS[@]}; do
    sudo bash -c 'echo '"$RS"' >> '"$HBASE_HOME"'/conf/regionservers'
done

# setup BackupMasters to the second node in the node list
sudo bash -c 'echo '"${ZK_HOSTNAME[1]}"' >> '"$HBASE_HOME"'/conf/backup-masters'

