#!/bin/bash

wget https://download.elastic.co/kibana/kibana/kibana-4.0.2-linux-x64.tar.gz -P ~/Downloads
sudo tar zxvf ~/Downloads/kibana-* -C /usr/local
sudo mv /usr/local/kibana-* /usr/local/kibana

echo -e "\nexport KIBANA_HOME=/usr/local/kibana\nexport PATH=\$PATH:\$KIBANA_HOME/bin\n" | cat >> ~/.profile

. ~/.profile

sudo chown -R ubuntu $KIBANA_HOME

