#!/bin/bash

REGION=us-west-2
PEM_NAME=insight-cluster
NUM_INSTANCES=4
SECURITY_GROUP=open
INSTANCE_TYPE=m4.xlarge
EBS_SIZE=400

CLUSTER_NAMES=(sparklab-austin)

for CLUSTER_NAME in ${CLUSTER_NAMES[@]}; do
  echo "spinning up $CLUSTER_NAME..."
  ./deploy_sparklab.sh -r $REGION -c $CLUSTER_NAME -i $PEM_NAME -n $NUM_INSTANCES -s $SECURITY_GROUP -t $INSTANCE_TYPE -e $EBS_SIZE
  echo -e "\n"
done


