#!/bin/bash

# check input arguments
if [ "$#" -ne 2 ]; then
    echo "Please specify pem-key location and cluster name" && exit 1
fi

PEMLOC=$1
INSTANCE_NAME=$2

# check if pem-key location is valid
if [ ! -f $PEMLOC ]; then
    echo "pem-key does not exist!" && exit 1
fi

if [ ! -d tmp/$INSTANCE_NAME ]; then
    echo "cluster does not exist!" && exit 1
fi

SSH/setup_passwordless_ssh.sh $PEMLOC $INSTANCE_NAME

install/Env/install_env_cluster.sh $PEMLOC $INSTANCE_NAME

./pass_aws_cred.sh $PEMLOC $INSTANCE_NAME

install/Hadoop/install_hadoop_cluster.sh $PEMLOC $INSTANCE_NAME
config/Hadoop/setup_cluster.sh $PEMLOC $INSTANCE_NAME

install/Hive/install_hive_cluster.sh $PEMLOC $INSTANCE_NAME
config/HIVE/setup_cluster.sh $PEMLOC $INSTANCE_NAME

install/Pig/install_pig_cluster.sh $PEMLOC $INSTANCE_NAME

install/Spark/install_spark_cluster.sh $PEMLOC $INSTANCE_NAME
config/Spark/setup_cluster.sh $PEMLOC $INSTANCE_NAME

install/Tachyon/install_tachyon_cluster.sh $PEMLOC $INSTANCE_NAME
config/Tachyon/setup_cluster.sh $PEMLOC $INSTANCE_NAME

install/Zeppelin/install_zeppelin_cluster.sh $PEMLOC $INSTANCE_NAME
config/Zeppelin/setup_cluster.sh $PEMLOC $INSTANCE_NAME
