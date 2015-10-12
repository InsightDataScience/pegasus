#!/bin/bash

REGION=us-west-2
CLUSTER_NAME=sparklab-austin
PEM_NAME=insight-cluster
NUM_INSTANCES=4
SECURITY_GROUPS=open
INSTANCE_TYPE=m4.large
EBS_SIZE=300


python spin_instances.py $REGION $CLUSTER_NAME $PEM_NAME $NUM_INSTANCES $SECURITY_GROUPS $INSTANCE_TYPE $EBS_SIZE

./install_hadoop.sh ~/.ssh/$PEM_NAME.pem $CLUSTER_NAME

./install_spark.sh ~/.ssh/$PEM_NAME.pem $CLUSTER_NAME

./sparklab_create_cred.sh ~/.ssh/$PEM_NAME.pem $CLUSTER_NAME
