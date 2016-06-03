#!/bin/bash

DNS=( "$@" )

source ~/.profile

ZK_SERVERS=""
for dns in ${DNS[@]}
do
    ZK_SERVERS=$ZK_SERVERS$dns:2181,
done

sudo sed -i 's@kafka-manager.zkhosts="kafka-manager-zookeeper:2181"@kafka-manager.zkhosts="'"${ZK_SERVERS:0:-1}"'"@g' $KAFKA_MANAGER_HOME/conf/application.conf
