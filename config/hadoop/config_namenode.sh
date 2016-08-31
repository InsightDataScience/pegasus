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

MASTER_NAME=$1; shift
SLAVE_NAME=( "$@" )

# configure hdfs-site.xml
sed -i '20i <property>\n  <name>dfs.replication</name>\n  <value>3</value>\n</property>' $HADOOP_HOME/etc/hadoop/hdfs-site.xml
sed -i '24i <property>\n  <name>dfs.namenode.name.dir</name>\n  <value>file:///usr/local/hadoop/hadoop_data/hdfs/namenode</value>\n</property>' $HADOOP_HOME/etc/hadoop/hdfs-site.xml
sudo mkdir -p $HADOOP_HOME/hadoop_data/hdfs/namenode

touch $HADOOP_HOME/etc/hadoop/masters
echo $MASTER_NAME | cat >> $HADOOP_HOME/etc/hadoop/masters

# add for additional datanodes
touch $HADOOP_HOME/etc/hadoop/slaves.new
for name in ${SLAVE_NAME[@]} 
do
    echo $name | cat >> $HADOOP_HOME/etc/hadoop/slaves.new
done
mv $HADOOP_HOME/etc/hadoop/slaves.new $HADOOP_HOME/etc/hadoop/slaves

sudo chown -R ubuntu $HADOOP_HOME
