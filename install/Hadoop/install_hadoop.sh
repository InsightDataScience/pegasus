#!/bin/bash

HADOOP_VER=2.7.1

if [ ! -f ~/Downloads/hadoop-$HADOOP_VER.tar.gz ]; then
  wget https://archive.apache.org/dist/hadoop/core/hadoop-$HADOOP_VER/hadoop-$HADOOP_VER.tar.gz -P ~/Downloads
  sudo tar zxvf ~/Downloads/hadoop-*.tar.gz -C /usr/local
  sudo mv /usr/local/hadoop-* /usr/local/hadoop
fi

if ! grep "export HADOOP_HOME" ~/.profile; then
  echo -e "\nexport HADOOP_HOME=/usr/local/hadoop\nexport PATH=\$PATH:\$HADOOP_HOME/bin" | cat >> ~/.profile
  echo -e "\nexport HADOOP_CONF_DIR=\$HADOOP_HOME/etc/hadoop" | cat >> ~/.profile

  . ~/.profile

  sudo chown -R ubuntu $HADOOP_HOME
fi
