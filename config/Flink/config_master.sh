#!/bin/bash
. ~/.profile;

MASTER_DNS=$1; shift
SLAVE_DNS=( "$@" )

mv $FLINK_HOME/conf/masters $FLINK_HOME/conf/masters.backup
echo $MASTER_DNS:8081 > $FLINK_HOME/conf/masters

mv $FLINK_HOME/conf/slaves $FLINK_HOME/conf/slaves.backup
touch $FLINK_HOME/conf/slaves;
for dns in ${SLAVE_DNS[@]}
do
    echo $dns | cat >> $FLINK_HOME/conf/slaves;
done

