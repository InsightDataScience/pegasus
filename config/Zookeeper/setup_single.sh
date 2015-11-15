#!/bin/bash

# first argument is the myid and all after are MASTER_DNS and SLAVE_DNS
ID=$1; shift
DNS=( "$@" )
LEN=${#DNS[@]}

. ~/.profile

cp $ZOOKEEPER_HOME/conf/zoo_sample.cfg $ZOOKEEPER_HOME/conf/zoo.cfg
sed -i 's@/tmp/zookeeper@/var/lib/zookeeper@g' $ZOOKEEPER_HOME/conf/zoo.cfg

for i in `seq $LEN`; do
    SERVER_NUM=$(echo "$LEN-$i+1" | bc)
    CURRENT_DNS=${DNS[$(echo "$SERVER_NUM-1" | bc)]}
    sed -i '15i server.'"$SERVER_NUM"'='"$CURRENT_DNS"':2888:3888' $ZOOKEEPER_HOME/conf/zoo.cfg
done

sudo mkdir /var/lib/zookeeper
sudo chown -R ubuntu /var/lib/zookeeper
sudo touch /var/lib/zookeeper/myid
echo 'echo '"$ID"' >> /var/lib/zookeeper/myid' | sudo -s

zkServer.sh start

