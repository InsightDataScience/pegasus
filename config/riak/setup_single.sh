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

# hostnames to name the riak node as riak@hostname

HOSTNAME=`hostname`
HOSTNAME=${HOSTNAME//-/.}
HOSTNAME=${HOSTNAME:3}

sudo sed -i 's@listener.protobuf.internal = 127.0.0.1:8087@listener.protobuf.internal = '"$HOSTNAME"':8087@g' /etc/riak/riak.conf
sudo sed -i 's@listener.http.internal = 127.0.0.1:8098@listener.http.internal = '"$HOSTNAME"':8098@g' /etc/riak/riak.conf
sudo sed -i 's@nodename = riak\@127.0.0.1@nodename = riak\@'"$HOSTNAME"'@g' /etc/riak/riak.conf

# increasing the open file limit for Riak
 
echo "ulimit -n 200000" | sudo tee -a /etc/default/riak

sudo /etc/init.d/riak start