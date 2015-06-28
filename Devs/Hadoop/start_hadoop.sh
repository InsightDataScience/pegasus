#!/bin/bash

. ~/.profile

hdfs namenode -format
$HADOOP_HOME/sbin/start-all.sh
$HADOOP_HOME/sbin/mr-jobhistory-daemon.sh start historyserver
