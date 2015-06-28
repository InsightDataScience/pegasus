#!/bin/bash

ELASTICSEARCH_DNS=$1

sudo apt-get update

wget https://download.elastic.co/kibana/kibana/kibana-4.0.2-linux-x64.tar.gz -P ~/Downloads
sudo tar zxvf ~/Downloads/kibana-* -C /usr/local
sudo mv /usr/local/kibana-* /usr/local/kibana

echo -e "\nexport KIBANA_HOME=/usr/local/kibana\nexport PATH=\$PATH:\$KIBANA_HOME/bin\n" | cat >> ~/.profile

. ~/.profile

sed -i 's@elasticsearch_url: "localhost:9200"@elasticsearch_url: "'"$ELASTICSEARCH_DNS"':9200"@g' $KIBANA_HOME/config/kibana.yml

sudo $KIBANA_HOME/bin/kibana &
