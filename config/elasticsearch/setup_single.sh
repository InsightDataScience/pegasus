#!/bin/bash

# first argument is the region, second is the ec2 security group, and last is the name of the elasticsearch cluster
ES_NAME=$1
AWS_REGION=$2
AWS_SECRET=$3
AWS_ACCESS=$4
QUORUM=$5

. ~/.profile

mkdir $ELASTICSEARCH_HOME/logs
mkdir $ELASTICSEARCH_HOME/plugins

sudo $ELASTICSEARCH_HOME/bin/plugin install cloud-aws
sudo $ELASTICSEARCH_HOME/bin/plugin install license
sudo $ELASTICSEARCH_HOME/bin/plugin install marvel-agent

sudo sed -i '1i discovery.type: ec2' $ELASTICSEARCH_HOME/config/elasticsearch.yml
sudo sed -i '1i cluster.name: '"$ES_NAME"'' $ELASTICSEARCH_HOME/config/elasticsearch.yml
sudo sed -i '1i cloud.aws.region: '"$AWS_REGION"'' $ELASTICSEARCH_HOME/config/elasticsearch.yml
sudo sed -i '1i cloud.aws.secret_key: '"$AWS_SECRET"'' $ELASTICSEARCH_HOME/config/elasticsearch.yml
sudo sed -i '1i cloud.aws.access_key: '"$AWS_ACCESS"'' $ELASTICSEARCH_HOME/config/elasticsearch.yml
sudo sed -i '1i network.host: 0.0.0.0' $ELASTICSEARCH_HOME/config/elasticsearch.yml
sudo sed -i '1i discovery.zen.minimum_master_nodes: '"$QUORUM"'' $ELASTICSEARCH_HOME/config/elasticsearch.yml
# discovery.zen.minimum_master_nodes: 1

sudo chown -R ubuntu $ELASTICSEARCH_HOME
