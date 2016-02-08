#!/bin/bash

. ~/.profile

sed -i "s@# cluster-enabled yes@cluster-enabled yes@g" $REDIS_HOME/redis.conf
sed -i 's@# cluster-config-file nodes-6379.conf@cluster-config-file nodes-6379.conf@g' $REDIS_HOME/redis.conf
sed -i 's@# cluster-node-timeout 15000@cluster-node-timeout 5000@g' $REDIS_HOME/redis.conf
sed -i 's@appendonly no@appendonly yes@g' $REDIS_HOME/redis.conf

cd $REDIS_HOME
make
cd ~

