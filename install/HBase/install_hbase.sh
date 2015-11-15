#!/bin/bash

wget http://mirror.symnds.com/software/Apache/hbase/stable/hbase-1.1.2-bin.tar.gz -P ~/Downloads
sudo tar zxvf ~/Downloads/hbase-*.tar.gz -C /usr/local
sudo mv /usr/local/hbase-* /usr/local/hbase

echo -e "\nexport HBASE_HOME=/usr/local/hbase\nexport PATH=\$PATH:\$HBASE_HOME/bin" >> ~/.profile

. ~/.profile

sudo chown -R ubuntu $HBASE_HOME

