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

echo "yes" | $REDIS_HOME/src/redis-trib.rb create --replicas 0 $REDIS_NODES &
