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

source ~/.profile

if [ ! -d /usr/local/kafka-manager ]; then
  sudo apt-get install unzip
  sudo git clone https://github.com/yahoo/kafka-manager.git
  cd ./kafka-manager
  sudo sbt clean dist 
  # wait
  sudo unzip ./target/universal/kafka-manager-*.zip -d /usr/local/
  sudo mv /usr/local/kafka-manager-* /usr/local/kafka-manager
  sudo rm -rf ~/kafka-manager
fi

if ! grep "export KAFKA_MANAGER_HOME" ~/.profile; then
  echo -e "\nexport KAFKA_MANAGER_HOME=/usr/local/kafka-manager\nexport PATH=\$PATH:\$KAFKA_MANAGER_HOME/bin" | cat >> ~/.profile
fi
source ~/.profile

sudo chown -R ubuntu $KAFKA_MANAGER_HOME
