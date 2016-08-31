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

