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

sed -i "s@# cluster-enabled yes@cluster-enabled yes@g" $REDIS_HOME/redis.conf
sed -i 's@# cluster-config-file nodes-6379.conf@cluster-config-file nodes-6379.conf@g' $REDIS_HOME/redis.conf
sed -i 's@# cluster-node-timeout 15000@cluster-node-timeout 5000@g' $REDIS_HOME/redis.conf
sed -i 's@appendonly no@appendonly yes@g' $REDIS_HOME/redis.conf

cd $REDIS_HOME
make
cd ~

