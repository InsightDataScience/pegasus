#!/bin/bash

MASTER_HOSTNAME=$1; shift
WORKER_HOSTNAMES=( "$@" )

. ~/.profile

cp $TACHYON_HOME/conf/tachyon-env.sh.template $TACHYON_HOME/conf/tachyon-env.sh

echo "export TACHYON_MASTER_ADDRESS=$MASTER_HOSTNAME" | cat >> ~/.profile
. ~/.profile

mv $TACHYON_HOME/conf/workers $TACHYON_HOME/conf/workers.backup
for worker in ${WORKER_HOSTNAMES[@]}
do
    echo $worker >> $TACHYON_HOME/conf/workers
done

