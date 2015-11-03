#!/bin/bash

REGION=us-west-2
PEM_NAME=insight-cluster
NUM_INSTANCES=4
SECURITY_GROUP=open
INSTANCE_TYPE=m4.large
EBS_SIZE=100
PRICE=0.04
AMI=ami-5189a661

CLUSTER_NAMES=(sparklab-test1)

for CLUSTER_NAME in ${CLUSTER_NAMES[@]}; do
  echo "spinning up $CLUSTER_NAME..."
  ./deploy_sparklab.sh -r $REGION -c $CLUSTER_NAME -i $PEM_NAME -n $NUM_INSTANCES -s $SECURITY_GROUP -t $INSTANCE_TYPE -e $EBS_SIZE -p $PRICE -a $AMI &
  echo -e "\n"
done


