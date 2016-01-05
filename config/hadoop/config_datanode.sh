#!/bin/bash
. ~/.profile

# configure hdfs-site.xml
sed -i '20i <property>\n  <name>dfs.replication</name>\n  <value>3</value>\n</property>' $HADOOP_HOME/etc/hadoop/hdfs-site.xml
sed -i '24i <property>\n  <name>dfs.datanode.data.dir</name>\n  <value>file:///usr/local/hadoop/hadoop_data/hdfs/datanode</value>\n</property>' $HADOOP_HOME/etc/hadoop/hdfs-site.xml

sudo mkdir -p $HADOOP_HOME/hadoop_data/hdfs/datanode

sudo chown -R ubuntu $HADOOP_HOME
