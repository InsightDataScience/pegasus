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

MASTER_DNS=$1; shift
MASTER_NAME=$1; shift
SLAVE_DNS_NAME=( "$@" )
LEN=${#SLAVE_DNS_NAME[@]}
HALF=$(echo "$LEN/2" | bc)
SLAVE_DNS=( "${SLAVE_DNS_NAME[@]:0:$HALF}" )
SLAVE_NAME=( "${SLAVE_DNS_NAME[@]:$HALF:$HALF}" )

# add for additional datanodes
sudo sed -i '2i '"$MASTER_DNS"' '"$MASTER_NAME"'' /etc/hosts

for (( i=0; i<$HALF; i++))
do
    echo $i ${SLAVE_DNS[$i]} ${SLAVE_NAME[$i]}
    sudo sed -i '3i '"${SLAVE_DNS[$i]}"' '"${SLAVE_NAME[$i]}"'' /etc/hosts
done

