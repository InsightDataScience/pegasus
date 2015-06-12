#!/bin/bash

# first argument is the region, second is the access_key, third is the secret_key and the rest is an array of all nodes in the cluster
NODEDNS=$1

sudo apt-get update

wget https://download.elastic.co/kibana/kibana/kibana-4.0.2-linux-x64.tar.gz -P ~/Downloads
sudo tar zxvf ~/Downloads/kibana-* -C /usr/local
sudo mv /usr/local/kibana-* /usr/local/kibana

echo -e "\nexport KIBANA_HOME=/usr/local/kibana\nexport PATH=\$PATH:\$KIBANA_HOME/bin\n" | cat >> ~/.profile

. ~/.profile

sed -i 's@elasticsearch_url: "localhost:9200"@elasticsearch_url: "'"$NODE_DNS"':9200"@g' $KIBANA_HOME/config/kibana.yml

sudo $KIBANA_HOME/bin/kibana &
