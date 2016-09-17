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

MASTER_NAME=$1
AWS_ACCESS_KEY_ID=$2
AWS_SECRET_ACCESS_KEY=$3

sed -i 's@${JAVA_HOME}@/usr@g' $HADOOP_HOME/etc/hadoop/hadoop-env.sh

sed -i '$a # Update Hadoop classpath to include share folder \nif [ \"$HADOOP_CLASSPATH\" ]; then \n export HADOOP_CLASSPATH=$HADOOP_CLASSPATH:$HADOOP_HOME/share/hadoop/tools/lib/* \nelse \n export HADOOP_CLASSPATH=$HADOOP_HOME/share/hadoop/tools/lib/* \nfi' $HADOOP_HOME/etc/hadoop/hadoop-env.sh

# configure core-site.xml
sed -i '20i <property>\n  <name>fs.defaultFS</name>\n  <value>hdfs://'"$MASTER_NAME"':9000</value>\n</property>' $HADOOP_HOME/etc/hadoop/core-site.xml
sed -i '24i <property>\n  <name>fs.s3.impl</name>\n  <value>org.apache.hadoop.fs.s3a.S3AFileSystem</value>\n</property>' $HADOOP_HOME/etc/hadoop/core-site.xml
sed -i '28i <property>\n  <name>fs.s3a.access.key</name>\n  <value>'"${AWS_ACCESS_KEY_ID}"'</value>\n</property>' $HADOOP_HOME/etc/hadoop/core-site.xml
sed -i '32i <property>\n  <name>fs.s3a.secret.key</name>\n  <value>'"${AWS_SECRET_ACCESS_KEY}"'</value>\n</property>' $HADOOP_HOME/etc/hadoop/core-site.xml

# configure yarn-site.xml
sed -i '18i <property>\n  <name>yarn.nodemanager.aux-services</name>\n  <value>mapreduce_shuffle</value>\n</property>' $HADOOP_HOME/etc/hadoop/yarn-site.xml
sed -i '22i <property>\n  <name>yarn.nodemanager.aux-services.mapreduce.shuffle.class</name>\n  <value>org.apache.hadoop.mapred.ShuffleHandler</value>\n</property>' $HADOOP_HOME/etc/hadoop/yarn-site.xml
sed -i '26i <property>\n  <name>yarn.resourcemanager.resource-tracker.address</name>\n  <value>'"$MASTER_NAME"':8025</value>\n</property>' $HADOOP_HOME/etc/hadoop/yarn-site.xml
sed -i '30i <property>\n  <name>yarn.resourcemanager.scheduler.address</name>\n  <value>'"$MASTER_NAME"':8030</value>\n</property>' $HADOOP_HOME/etc/hadoop/yarn-site.xml
sed -i '34i <property>\n  <name>yarn.resourcemanager.address</name>\n  <value>'"$MASTER_NAME"':8050</value>\n</property>' $HADOOP_HOME/etc/hadoop/yarn-site.xml

# configure mapred-site.xml
cp $HADOOP_HOME/etc/hadoop/mapred-site.xml.template $HADOOP_HOME/etc/hadoop/mapred-site.xml
sed -i '20i <property>\n  <name>mapreduce.jobtracker.address</name>\n  <value>'"$MASTER_NAME"':54311</value>\n</property>' $HADOOP_HOME/etc/hadoop/mapred-site.xml
sed -i '24i <property>\n  <name>mapreduce.framework.name</name>\n  <value>yarn</value>\n</property>' $HADOOP_HOME/etc/hadoop/mapred-site.xml
sed -i '28i <property>\n <name>mapreduce.application.classpath</name>\n <value>'"$HADOOP_HOME"'/share/hadoop/mapreduce/*,'"$HADOOP_HOME"'/share/hadoop/mapreduce/lib/*,'"$HADOOP_HOME"'/share/hadoop/common/*,'"$HADOOP_HOME"'/share/hadoop/common/lib/*,'"$HADOOP_HOME"'/share/hadoop/tools/lib/*</value> \n </property>' $HADOOP_HOME/etc/hadoop/mapred-site.xml
