#!/bin/bash

wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.5.2.tar.gz -P ~/Downloads
sudo tar zxvf ~/Downloads/elasticsearch-1.5.2.tar.gz -C /usr/local
sudo mv /usr/local/elasticsearch-1.5.2 /usr/local/elasticsearch

echo -e "\nexport ELASTICSEARCH_HOME=/usr/local/elasticsearch\nexport PATH=\$PATH:\$ELASTICSEARCH_HOME/bin\n" | cat >> ~/.profile

. ~/.profile

sudo chown -R ubuntu $ELASTICSEARCH_HOME

