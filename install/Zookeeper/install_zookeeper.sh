#!/bin/bash

wget http://mirror.cc.columbia.edu/pub/software/apache/zookeeper/stable/zookeeper-3.4.6.tar.gz -P ~/Downloads
sudo tar zxvf ~/Downloads/zookeeper-3.4.6.tar.gz -C /usr/local
sudo mv /usr/local/zookeeper-3.4.6/ /usr/local/zookeeper

echo -e "\nexport ZOOKEEPER_HOME=/usr/local/zookeeper\nexport PATH=\$PATH:\$ZOOKEEPER_HOME:\$ZOOKEEPER_HOME/bin" >> ~/.profile

. ~/.profile

sudo chown -R ubuntu $ZOOKEEPER_HOME

