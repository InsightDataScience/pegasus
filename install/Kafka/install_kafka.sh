#!/bin/bash

wget http://www.interior-dsgn.com/apache/kafka/0.8.2.2/kafka_2.10-0.8.2.2.tgz -P ~/Downloads
sudo tar zxvf ~/Downloads/kafka_*.tgz -C /usr/local
sudo mv /usr/local/kafka_* /usr/local/kafka

echo -e "\nexport KAFKA_HOME=/usr/local/kafka\nexport PATH=\$PATH:\$KAFKA_HOME:\$KAFKA_HOME/bin" >> ~/.profile

. ~/.profile

sudo chown -R ubuntu $KAFKA_HOME

