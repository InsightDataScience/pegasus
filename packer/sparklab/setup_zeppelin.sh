#!/bin/bash

git clone https://github.com/apache/incubator-zeppelin.git
sudo mv incubator-zeppelin /usr/local
sudo mv /usr/local/incubator-zeppelin /usr/local/zeppelin

echo -e "\nexport ZEPPELIN_HOME=/usr/local/zeppelin" | cat >> ~/.profile
echo -e "\nexport PATH=\$PATH:\$ZEPPELIN_HOME/bin" | cat >> ~/.profile

. ~/.profile

sudo chown -R ubuntu $ZEPPELIN_HOME

cd $ZEPPELIN_HOME
sudo mvn clean package -Pspark-1.4 -Dhadoop.version=2.2.0 -Phadoop-2.2 -DskipTests

