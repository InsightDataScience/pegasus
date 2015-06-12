#!/bin/bash

sudo apt-get update

sudo apt-get --yes --force-yes install openjdk-7-jdk

wget http://mirror.symnds.com/software/Apache/flink/flink-0.8.1/flink-0.8.1-bin-hadoop2.tgz -P ~/Downloads

sudo tar -zxvf ~/Downloads/flink-* -C /usr/local
sudo mv /usr/local/flink-* /usr/local/flink

echo -e "\nexport FLINK_HOME=/usr/local/flink\nexport PATH=\$PATH:\$FLINK_HOME/bin" | cat >> ~/.profile

. ~/.profile


