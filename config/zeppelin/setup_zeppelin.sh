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

cp $ZEPPELIN_HOME/conf/zeppelin-env.sh.template $ZEPPELIN_HOME/conf/zeppelin-env.sh
cp $ZEPPELIN_HOME/conf/zeppelin-site.xml.template $ZEPPELIN_HOME/conf/zeppelin-site.xml

sed -i '18i export JAVA_HOME=/usr' $ZEPPELIN_HOME/conf/zeppelin-env.sh
sed -i '18i export MASTER=spark://'$(hostname)':7077' $ZEPPELIN_HOME/conf/zeppelin-env.sh
sed -i '18i export SPARK_HOME='$SPARK_HOME'' $ZEPPELIN_HOME/conf/zeppelin-env.sh

MEMINFO=($(free -m | sed -n '2p' | sed -e "s/[[:space:]]\+/ /g"))
TOTMEM=${MEMINFO[1]}
EXECMEM=$(echo "0.90 * ($TOTMEM - 1000)" | bc -l)
#sed -i '18i export SPARK_SUBMIT_OPTIONS="--driver-memory '${EXECMEM%.*}'M --executor-memory '${EXECMEM%.*}'M"' $ZEPPELIN_HOME/conf/zeppelin-env.sh

sed -i 's@<value>8080</value>@<value>7888</value>@g' $ZEPPELIN_HOME/conf/zeppelin-site.xml

