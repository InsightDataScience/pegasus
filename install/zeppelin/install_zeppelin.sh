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

if [ ! -d /usr/local/zeppelin ]; then
  git clone https://github.com/apache/incubator-zeppelin.git
  sudo mv incubator-zeppelin /usr/local
  sudo mv /usr/local/incubator-zeppelin /usr/local/zeppelin
fi

if ! grep "export ZEPPELIN_HOME" ~/.profile; then
  echo -e "\nexport ZEPPELIN_HOME=/usr/local/zeppelin\nexport PATH=\$PATH:\$ZEPPELIN_HOME/bin" | cat >> ~/.profile

  . ~/.profile

  sudo chown -R ubuntu $ZEPPELIN_HOME

  cd $ZEPPELIN_HOME
  sudo mvn clean package -Pspark-1.4 -Dhadoop.version=2.2.0 -Phadoop-2.2 -DskipTests &
  wait
  echo "Zeppelin installed"
fi
