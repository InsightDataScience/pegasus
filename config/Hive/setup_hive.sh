#!/bin/bash

. ~/.profile

hdfs dfs -mkdir /tmp
hdfs dfs -mkdir -p /user/hive/warehouse
hdfs dfs -chmod g+w /tmp
hdfs dfs -chmod g+w /user/hive/warehouse
hdfs dfs -chmod 1777 /user/hive/warehouse
