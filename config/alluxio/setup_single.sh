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

MASTER_HOSTNAME=$1; shift
WORKER_HOSTNAMES=( "$@" )

. ~/.profile

cp $ALLUXIO_HOME/conf/alluxio-env.sh.template $ALLUXIO_HOME/conf/alluxio-env.sh

echo "export ALLUXIO_MASTER_ADDRESS=$MASTER_HOSTNAME" | cat >> ~/.profile
. ~/.profile

mv $ALLUXIO_HOME/conf/workers $ALLUXIO_HOME/conf/workers.backup
for worker in ${WORKER_HOSTNAMES[@]}
do
    echo $worker >> $ALLUXIO_HOME/conf/workers
done

