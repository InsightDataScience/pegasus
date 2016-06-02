#!/bin/bash

source ~/.profile

if [ ! -d /usr/local/kafka-manager ]; then
  sudo apt-get install unzip
  sudo git clone https://github.com/yahoo/kafka-manager.git
  cd ./kafka-manager
  sudo sbt clean dist 
  # wait
  sudo unzip ./target/universal/kafka-manager-*.zip -d /usr/local/
  sudo mv /usr/local/kafka-manager-* /usr/local/kafka-manager
  sudo rm -rf ~/kafka-manager
fi

if ! grep "export KAFKA_MANAGER_HOME" ~/.profile; then
  echo -e "\nexport KAFKA_MANAGER_HOME=/usr/local/kafka-manager\nexport PATH=\$PATH:\$KAFKA_MANAGER_HOME/bin" | cat >> ~/.profile
fi
source ~/.profile

sudo chown -R ubuntu $KAFKA_MANAGER_HOME
