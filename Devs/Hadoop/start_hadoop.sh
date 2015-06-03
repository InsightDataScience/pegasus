#!/bin/bash

. ~/.profile

hdfs namenode -format

# These commands must be explicity entered on the Namenode due to the hosts not being added correctly to known hosts in ~/.ssh
#$HADOOP_HOME/sbin/start-dfs.sh
#$HADOOP_HOME/sbin/start-yarn.sh
#$HADOOP_HOME/sbin/mr-jobhistory-daemon.sh start historyserver
