#!/bin/bash

sudo apt-get update
sudo apt-get -y install git
git clone https://github.com/InsightDataScience/pegasus.git

pegasus/install/Environment/install_env.sh
pegasus/install/download_tech hadoop
pegasus/install/download_tech hive
pegasus/install/download_tech pig
pegasus/install/download_tech spark
pegasus/install/download_tech tachyon
pegasus/install/Zeppelin/install_zeppelin.sh
