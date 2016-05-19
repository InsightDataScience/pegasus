#!/bin/bash

sudo apt-get update
sudo apt-get -y install git
git clone https://github.com/InsightDataScience/pegasus.git

pegasus/install/Environment/install_env.sh
pegasus/install/download_tech hadoop
pegasus/install/download_tech hive
pegasus/install/download_tech pig
pegasus/install/download_tech spark
pegasus/install/download_tech alluxio
pegasus/install/download_tech elasticsearch
pegasus/install/download_tech cassandra
pegasus/install/download_tech redis
pegasus/install/download_tech zookeeper
pegasus/install/download_tech kafka
pegasus/install/download_tech storm
pegasus/install/download_tech flink
pegasus/install/download_tech hbase
pegasus/install/download_tech kibana
pegasus/install/download_tech presto
pegasus/install/Zeppelin/install_zeppelin.sh
