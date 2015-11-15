#!/bin/bash

PURCHASE_TYPE=on_demand
REGION=us-west-2
AZ=us-west-2b
PEM_NAME=insight-cluster
NUM_INSTANCES=4
SECURITY_GROUP=open
INSTANCE_TYPE=m4.large
EBS_SIZE=400
PRICE=0.08
AMI=ami-f30b1c92

CLUSTER_NAMES=(austin-spark-cluster)

for CLUSTER_NAME in ${CLUSTER_NAMES[@]}; do
  echo "spinning up $CLUSTER_NAME..."
  time ./config_and_start_sparklab.sh -u $PURCHASE_TYPE -r $REGION -z $AZ -c $CLUSTER_NAME -i $PEM_NAME -n $NUM_INSTANCES -s $SECURITY_GROUP -t $INSTANCE_TYPE -e $EBS_SIZE -p $PRICE -a $AMI &
  echo -e "\n"
done


