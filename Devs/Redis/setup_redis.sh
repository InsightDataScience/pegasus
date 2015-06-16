#!/bin/bash

sudo apt-get update
sudo apt-get --yes --force-yes install make gcc ruby-full
sudo gem install redis

wget http://download.redis.io/releases/redis-3.0.2.tar.gz -P ~/Downloads

sudo tar zxvf ~/Downloads/redis-* -C /usr/local
sudo mv /usr/local/redis-* /usr/local/redis

echo -e "\nexport REDIS_HOME=/usr/local/redis\nexport PATH=\$PATH:\$REDIS_HOME/src" >> ~/.profile

. ~/.profile

cd $REDIS_HOME
sudo make distclean
sudo make

#sudo sed -i 's@appendonly no@appendonly yes@g' $REDIS_HOME/redis.conf
#sudo sed -i 's@# cluster-enabled yes@cluster-enabled yes@g' $REDIS_HOME/redis.conf
#sudo sed -i 's@# cluster-config-file@cluster-config-file@g' $REDIS_HOME/redis.conf
#sudo sed -i 's@# cluster-node-timeout@cluster-node-timeout@g' $REDIS_HOME/redis.conf

sudo $REDIS_HOME/src/redis-server $REDIS_HOME/redis.conf &
