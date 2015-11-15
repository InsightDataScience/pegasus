#!/bin/bash

SPARK_VER=1.5.1
HADOOP_VER=2.4

if [ ! -f ~/Downloads/spark-$SPARK_VER-bin-hadoop$HADOOP_VER.tgz ]; then
  wget http://apache.osuosl.org/spark/spark-$SPARK_VER/spark-$SPARK_VER-bin-hadoop$HADOOP_VER.tgz -P ~/Downloads

  sudo tar zxvf ~/Downloads/spark-* -C /usr/local
  sudo mv /usr/local/spark-* /usr/local/spark
fi

if ! grep "export SPARK_HOME" ~/.profile; then
  echo -e "\nexport SPARK_HOME=/usr/local/spark\nexport PATH=\$PATH:\$SPARK_HOME/bin" | cat >> ~/.profile
  . ~/.profile

  sudo chown -R ubuntu $SPARK_HOME
fi

