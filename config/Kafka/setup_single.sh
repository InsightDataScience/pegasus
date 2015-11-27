#!/bin/bash

# first argument is the brokerid and all after are MASTER_DNS and SLAVE_DNS
ID=$1; shift
PUBLIC_DNS=$1; shift
DNS=( "$@" )

. ~/.profile

sudo sed -i 's@broker.id=0@broker.id='"$ID"'@g' /usr/local/kafka/config/server.properties
sudo sed -i 's@#advertised.host.name=<hostname routable by clients>@advertised.host.name='"$PUBLIC_DNS"'@g' /usr/local/kafka/config/server.properties

ZK_SERVERS=""
for dns in ${DNS[@]}
do
    ZK_SERVERS=$ZK_SERVERS$dns:2181,
done

sudo sed -i 's@localhost:2181@'"${ZK_SERVERS:0:-1}"'@g' /usr/local/kafka/config/server.properties

tmux new-session -s kafka_server -n bash -d

tmux send-keys -t kafka_server 'sudo /usr/local/kafka/bin/kafka-server-start.sh /usr/local/kafka/config/server.properties' C-m

