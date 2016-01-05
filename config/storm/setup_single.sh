#!/bin/bash

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
numbus.host: "${CLUSTER_DNS[0]}"
storm.local.dir: "$STORM_LOCAL_DIR"
supervisor.slots.ports:
$SUPERVISOR_PORTS
EOL
