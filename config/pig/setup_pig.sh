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

sudo apt-get update

wget http://mirror.tcpdiag.net/apache/pig/pig-0.14.0/pig-0.14.0.tar.gz -P ~/Downloads
sudo tar -zxvf ~/Downloads/pig-*.tar.gz -C /usr/local
sudo mv /usr/local/pig-* /usr/local/pig

echo -e "\nexport PIG_HOME=/usr/local/pig\nexport PATH=\$PATH:\$PIG_HOME/bin\n" | cat >> ~/.profile

. ~/.profile
