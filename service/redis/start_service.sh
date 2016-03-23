#!/bin/bash

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..
source ${PEG_ROOT}/util.sh

if [ "$#" -ne 1 ]; then
    echo "Please specify cluster name!" && exit 1
fi

CLUSTER_NAME=$1

PUBLIC_DNS=$(fetch_cluster_public_dns ${CLUSTER_NAME})
MASTER_DNS=$(fetch_cluster_master_public_dns ${CLUSTER_NAME})

# Start redis servers
for dns in ${PUBLIC_DNS};
do
  cmd='/usr/local/redis/src/redis-server /usr/local/redis/redis.conf &'
  run_cmd_on_node ${dns} ${cmd} &
done

wait

# begin discovery of redis servers
sleep 5

script=${PEG_ROOT}/config/redis/join_redis_cluster.sh
args="${PUBLIC_DNS}"
run_script_on_node ${MASTER_DNS} ${script} ${args} &

echo "Redis Started!"
