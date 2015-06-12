#!/bin/bash

# first argument is the region, second is the access_key, third is the secret_key and the rest is an array of all nodes in the cluster
REGION=$1; shift
AWS_ACCESS_KEY=$1; shift
AWS_SECRET_KEY=$1; shift
EC2_GROUP=$1; shift
DNS=( "$@" )

sudo apt-get update

sudo apt-get --yes --force-yes install openjdk-7-jdk

wget https://download.elasticsearch.org/elasticsearch/elasticsearch/elasticsearch-1.5.2.tar.gz -P ~/Downloads
sudo tar zxvf ~/Downloads/elasticsearch-1.5.2.tar.gz -C /usr/local
sudo mv /usr/local/elasticsearch-1.5.2 /usr/local/elasticsearch

echo -e "\nexport ELASTICSEARCH_HOME=/usr/local/elasticsearch\nexport PATH=\$PATH:\$ELASTICSEARCH_HOME/bin\n" | cat >> ~/.profile

. ~/.profile

sudo $ELASTICSEARCH_HOME/bin/plugin install elasticsearch/elasticsearch-cloud-aws/2.5.0

sudo sed -i '1i discovery.ec2.groups: '"$EC2_GROUP"'' $ELASTICSEARCH_HOME/config/elasticsearch.yml
sudo sed -i '1i discovery.type: ec2' $ELASTICSEARCH_HOME/config/elasticsearch.yml
sudo sed -i '1i cloud.aws.region: '"$REGION"'' $ELASTICSEARCH_HOME/config/elasticsearch.yml
sudo sed -i '1i cloud.aws.secret_key: '"$AWS_SECRET_KEY"'' $ELASTICSEARCH_HOME/config/elasticsearch.yml
sudo sed -i '1i cloud.aws.access_key: '"$AWS_ACCESS_KEY"'' $ELASTICSEARCH_HOME/config/elasticsearch.yml

#sudo $ELASTICSEARCH_HOME/bin/elasticsearch &
