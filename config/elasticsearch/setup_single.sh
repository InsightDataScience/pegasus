#!/bin/bash

# first argument is the region, second is the ec2 security group, and last is the name of the elasticsearch cluster
ES_NAME=$1

. ~/.profile

sudo $ELASTICSEARCH_HOME/bin/plugin install cloud-aws

#sudo sed -i '1i discovery.ec2.groups: '"$EC2_GROUP"'' $ELASTICSEARCH_HOME/config/elasticsearch.yml
sudo sed -i '1i discovery.type: ec2' $ELASTICSEARCH_HOME/config/elasticsearch.yml
sudo sed -i '1i cluster.name: '"$ES_NAME"'' $ELASTICSEARCH_HOME/config/elasticsearch.yml
sudo sed -i '1i cloud.aws.region: '"$AWS_DEFAULT_REGION"'' $ELASTICSEARCH_HOME/config/elasticsearch.yml
sudo sed -i '1i cloud.aws.secret_key: '"$AWS_SECRET_ACCESS_KEY"'' $ELASTICSEARCH_HOME/config/elasticsearch.yml
sudo sed -i '1i cloud.aws.access_key: '"$AWS_ACCESS_KEY_ID"'' $ELASTICSEARCH_HOME/config/elasticsearch.yml
sudo sed -1 '1i network.host: 0.0.0.0' $ELASTICSEARCH_HOME/config/elasticsearch.yml

