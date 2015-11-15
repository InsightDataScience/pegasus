#!/bin/bash

. ~/.profile

MASTER_NAME=$1

sed -i 's@${JAVA_HOME}@/usr@g' $HADOOP_HOME/etc/hadoop/hadoop-env.sh

# configure core-site.xml
sed -i '20i <property>\n  <name>fs.defaultFS</name>\n  <value>hdfs://'"$MASTER_NAME"':9000</value>\n</property>' $HADOOP_HOME/etc/hadoop/core-site.xml

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

