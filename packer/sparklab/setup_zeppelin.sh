#!/bin/bash

wget http://supergsego.com/apache/incubator/zeppelin/0.5.0-incubating/zeppelin-0.5.0-incubating-bin-spark-1.4.0_hadoop-2.3.tgz -P ~/Downloads

sudo tar zxvf ~/Downloads/zeppelin-* -C /usr/local
sudo mv /usr/local/zeppelin-* /usr/local/zeppelin

echo -e "\nexport ZEPPELIN_HOME=/usr/local/zeppelin\nexport PATH=\$PATH:\$ZEPPELIN_HOME/bin" | cat >> ~/.profile
. ~/.profile

sudo chown -R ubuntu $ZEPPELIN_HOME

