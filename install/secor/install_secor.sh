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

if [ ! -d /usr/local/secor ]; then
  cd /usr/local
  sudo git clone https://github.com/pinterest/secor.git
  sudo mkdir /usr/local/secor/bin
fi

if ! grep "export SECOR_HOME" ~/.profile; then
  echo -e "\nexport SECOR_HOME=/usr/local/secor\nexport PATH=\$PATH:\$SECOR_HOME/bin" | cat >> ~/.profile
fi
. ~/.profile

sudo chown -R ubuntu $SECOR_HOME

cd $SECOR_HOME
sudo mvn clean package &
wait
sudo tar -zxvf ./target/secor-*-SNAPSHOT-bin.tar.gz -C ./bin/
