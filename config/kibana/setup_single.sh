#!/bin/bash

ELASTICSEARCH_DNS=$1

. ~/.profile

sed -i 's@elasticsearch_url: "localhost:9200"@elasticsearch_url: "'"$ELASTICSEARCH_DNS"':9200"@g' $KIBANA_HOME/config/kibana.yml

sudo $KIBANA_HOME/bin/kibana &
