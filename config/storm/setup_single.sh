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

. ~/.profile

NUM_WORKERS=$1; shift
CLUSTER_DNS=( "$@" )

WORKER_PORT=6700

STORM_LOCAL_DIR=/var/storm
sudo mkdir -p $STORM_LOCAL_DIR
sudo chown -R ubuntu $STORM_LOCAL_DIR

ZK_SERVERS=""
for DNS in ${CLUSTER_DNS[@]}; do
  ZK_SERVERS+="    - \"$DNS\""$'\n'
done

SUPERVISOR_PORTS=""
for SLOT_NUM in `seq $NUM_WORKERS`; do
  PORT_NUM=$(echo "$WORKER_PORT + $SLOT_NUM - 1" | bc -l)
  SUPERVISOR_PORTS+="    - $PORT_NUM"$'\n'
done

# storm.yaml
cat >> $STORM_HOME/conf/storm.yaml << EOL
storm.zookeeper.servers:
$ZK_SERVERS
nimbus.host: "${CLUSTER_DNS[0]}"
storm.local.dir: "$STORM_LOCAL_DIR"
supervisor.slots.ports:
$SUPERVISOR_PORTS
EOL
