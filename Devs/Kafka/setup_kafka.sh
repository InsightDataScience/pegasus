#!/bin/bash

# first argument is the brokerid and all after are MASTER_DNS and SLAVE_DNS
ID=$1; shift
PUBLIC_DNS=$1; shift
DNS=( "$@" )

sudo apt-get update

sudo apt-get --yes --force-yes install openjdk-7-jdk

wget http://apache.claz.org/kafka/0.8.2.1/kafka_2.9.1-0.8.2.1.tgz -P ~/Downloads
sudo tar zxvf ~/Downloads/kafka_2.9.1-0.8.2.1.tgz -C /usr/local
sudo mv /usr/local/kafka_2.9.1-0.8.2.1 /usr/local/kafka

sudo sed -i 's@broker.id=0@broker.id='"$ID"'@g' /usr/local/kafka/config/server.properties
sudo sed -i 's@#advertised.host.name=<hostname routable by clients>@advertised.host.name='"$PUBLIC_DNS"'@g' /usr/local/kafka/config/server.properties

ZK_SERVERS=""
for dns in ${DNS[@]}
do
    ZK_SERVERS=$ZK_SERVERS$dns:2181,
done

sudo sed -i 's@localhost:2181@'"${ZK_SERVERS:0:-1}"'@g' /usr/local/kafka/config/server.properties

sudo /usr/local/kafka/bin/kafka-server-start.sh /usr/local/kafka/config/server.properties &
