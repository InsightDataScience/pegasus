#!/bin/bash

sudo apt-get update

wget http://mirror.tcpdiag.net/apache/pig/pig-0.14.0/pig-0.14.0.tar.gz -P ~/Downloads
sudo tar -zxvf ~/Downloads/pig-*.tar.gz -C /usr/local
sudo mv /usr/local/pig-* /usr/local/pig

echo -e "\nexport PIG_HOME=/usr/local/pig\nexport PATH=\$PATH:\$PIG_HOME/bin\n" | cat >> ~/.profile

. ~/.profile
