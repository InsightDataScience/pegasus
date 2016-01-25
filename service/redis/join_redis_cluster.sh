#!/bin/bash

PUBLIC_DNS=( "$@" )
PORT=6379

. ~/.profile

sudo gem install redis

extract_ip_from_dns () {
  SPLIT_ARR=(${1//./ })
  DNS_PART_0=${SPLIT_ARR[0]}
  DNS_PART_0_ARR=(${DNS_PART_0//-/ })
  IP_SPLIT=${DNS_PART_0_ARR[@]:1}
  IP=${IP_SPLIT// /.}
}

REDIS_NODES=""
for DNS in ${PUBLIC_DNS[@]}; do
  extract_ip_from_dns $DNS
  REDIS_NODES+=$IP:$PORT\ 
done

echo $REDIS_NODES

echo "yes" | $REDIS_HOME/src/redis-trib.rb create --replicas 0 $REDIS_NODES
