#!/bin/bash

HADOOP_VER=2.7.1

wget http://mirror.symnds.com/software/Apache/hadoop/common/hadoop-$HADOOP_VER/hadoop-$HADOOP_VER.tar.gz -P ~/Downloads
sudo tar zxvf ~/Downloads/hadoop-*.tar.gz -C /usr/local
sudo mv /usr/local/hadoop-* /usr/local/hadoop

echo -e "\nexport HADOOP_HOME=/usr/local/hadoop\nexport PATH=\$PATH:\$HADOOP_HOME/bin\n" | cat >> ~/.profile
echo -e "\nexport HADOOP_CONF_DIR=\$HADOOP_HOME/etc/hadoop\n" | cat >> ~/.profile

. ~/.profile

sudo chown -R ubuntu $HADOOP_HOME
