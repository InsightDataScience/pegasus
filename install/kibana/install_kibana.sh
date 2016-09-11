#!/bin/bash

source ~/.profile

if [ ! -d /usr/local/secor ]; then
  cd /usr/local
  sudo git clone https://github.com/pinterest/secor.git
  sudo mkdir /usr/local/secor/bin
fi

if ! grep "export SECOR_HOME" ~/.profile; then
  echo -e "\nexport SECOR_HOME=/usr/local/secor\nexport PATH=\$PATH:\$SECOR_HOME/bin" | cat >> ~/.profile
fi
. ~/.profile

sudo chown -R ubuntu $SECOR_HOME

cd $SECOR_HOME
sudo mvn clean package &
wait
sudo tar -zxvf ./target/secor-*-SNAPSHOT-bin.tar.gz -C ./bin/
