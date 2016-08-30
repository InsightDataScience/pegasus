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

NAMENODE_DNS=$1; shift
NAMENODE_HOSTNAME=$1; shift
DATANODE_HOSTNAMES="$@"

# add NameNode to known_hosts
ssh-keyscan -H -t ecdsa $NAMENODE_DNS >> ~/.ssh/known_hosts

# add DataNodes to known_hosts
for hostname in ${DATANODE_HOSTNAMES}; do
    echo "Adding $hostname to known hosts..."
    ssh-keyscan -H -t ecdsa $hostname >> ~/.ssh/known_hosts
done

# add Secondary NameNode to known_hosts
ssh-keyscan -H -t ecdsa 0.0.0.0 >> ~/.ssh/known_hosts

# add localhost and 127.0.0.1 to known_hosts
ssh-keyscan -H -t ecdsa localhost >> ~/.ssh/known_hosts
ssh-keyscan -H -t ecdsa 127.0.0.1 >> ~/.ssh/known_hosts
