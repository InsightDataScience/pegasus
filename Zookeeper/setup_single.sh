#!/bin/bash

# first argument is the myid and all after are MASTER_DNS and SLAVE_DNS
ID=$1; shift
DNS=( "$@" )
LEN=${#DNS[@]}

sudo apt-get update

sudo apt-get --yes --force-yes install openjdk-7-jdk

wget http://mirror.cc.columbia.edu/pub/software/apache/zookeeper/stable/zookeeper-3.4.6.tar.gz -P ~/Downloads
sudo tar zxvf ~/Downloads/zookeeper-3.4.6.tar.gz -C /usr/local
sudo mv /usr/local/zookeeper-3.4.6/ /usr/local/zookeeper

cp /usr/local/zookeeper/conf/zoo_sample.cfg /usr/local/zookeeper/conf/zoo.cfg
sed -i 's@/tmp/zookeeper@/var/lib/zookeeper@g' /usr/local/zookeeper/conf/zoo.cfg

for i in `seq $LEN`; do
    SERVER_NUM=$(echo "$LEN-$i+1" | bc)
    CURRENT_DNS=${DNS[$(echo "$SERVER_NUM-1" | bc)]}
    sed -i '15i server.'"$SERVER_NUM"'='"$CURRENT_DNS"':2888:3888' /usr/local/zookeeper/conf/zoo.cfg
done

sudo mkdir /var/lib/zookeeper
sudo touch /var/lib/zookeeper/myid
echo 'echo '"$ID"' >> /var/lib/zookeeper/myid' | sudo -s

sudo /usr/local/zookeeper/bin/zkServer.sh start

