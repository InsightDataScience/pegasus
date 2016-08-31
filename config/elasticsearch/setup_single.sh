#!/bin/bash

# Copyright 2015 Insight Data Science
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# first argument is the region, second is the ec2 security group, and last is the name of the elasticsearch cluster
ES_NAME=$1; shift
AWS_REGION=$1; shift
AWS_SECRET=$1; shift
AWS_ACCESS=$1; shift
QUORUM=$1; shift
HOSTNAMES=( "$@" )

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

ES_HOSTS=""
for host in ${HOSTNAMES[@]}
do
	ES_HOSTS=$ES_HOSTS\"$host\",
done

sudo sed -i '1i discovery.zen.ping.unicast.hosts: '\["${ES_HOSTS:0:-1}"\]'' $ELASTICSEARCH_HOME/config/elasticsearch.yml

sudo chown -R ubuntu $ELASTICSEARCH_HOME
