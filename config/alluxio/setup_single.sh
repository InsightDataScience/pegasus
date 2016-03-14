#!/bin/bash

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

