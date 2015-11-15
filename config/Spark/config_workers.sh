#!/bin/bash
. ~/.profile;

SLAVE_DNS=( "$@" )

touch $SPARK_HOME/conf/slaves;
for dns in ${SLAVE_DNS[@]}
do
    echo $dns | cat >> $SPARK_HOME/conf/slaves;
done

