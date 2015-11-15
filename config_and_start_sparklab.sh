#!/bin/bash

while getopts ":u:r:z:c:i:n:s:t:e:p:a:h" opt; do
  case $opt in
    u) PURCHASE_TYPE=$OPTARG
       echo "          purchase type: $PURCHASE_TYPE" ;;
    r) REGION=$OPTARG
       echo "                 region: $REGION" ;;
    z) AZ=$OPTARG
       echo "      availability zone: $AZ" ;;
    c) CLUSTER_NAME=$OPTARG
       echo "           cluster name: $CLUSTER_NAME" ;;
    i) PEM_NAME=$OPTARG
       echo "           pem key name: $PEM_NAME" ;;
    n) NUM_INSTANCES=$OPTARG
       echo "    number of instances: $NUM_INSTANCES" ;;
    s) SECURITY_GROUP=$OPTARG
       echo "         security group: $SECURITY_GROUP" ;;
    t) INSTANCE_TYPE=$OPTARG
       echo "          instance type: $INSTANCE_TYPE" ;;
    e) EBS_SIZE=$OPTARG
       echo "default EBS volume size: $EBS_SIZE" ;;
    p) PRICE=$OPTARG
       echo "         spot bid price: $PRICE" ;;
    a) AMI=$OPTARG
       echo "                    AMI: $AMI" ;;
    h) echo "Use the following options:"
       echo "-r: Region"
       echo "-c: Cluster Name"
       echo "-i: Pem Key Name"
       echo "-n: Number of Instances"
       echo "-s: Security Group Name"
       echo "-t: Instance Type"
       echo "-e: Default EBS Volume Size"
       echo "-p: Spot Instance Bid Price"
       echo "-a: AMI to run on instances"
       ;;
    \?) echo "Invalid option: -$OPTARG" >&2
        echo "use -h option for input argument tags"
        exit 1
        ;;
    :) echo "Option -$OPTARG requires an arument." >&2; exit 1 ;;
  esac
done

# remove tmp directory with instance name
rm -rf tmp/$CLUSTER_NAME

python spin_up.py $PURCHASE_TYPE $REGION $AZ $CLUSTER_NAME $PEM_NAME $NUM_INSTANCES $SECURITY_GROUP $INSTANCE_TYPE $EBS_SIZE $PRICE $AMI
 
#python spin_spot.py $REGION $CLUSTER_NAME $PEM_NAME $NUM_INSTANCES $SECURITY_GROUP $INSTANCE_TYPE $EBS_SIZE $PRICE $AMI
#python spin_demand.py $REGION $CLUSTER_NAME $PEM_NAME $NUM_INSTANCES $SECURITY_GROUP $INSTANCE_TYPE $EBS_SIZE $AMI

SSH/setup_passwordless_ssh.sh ~/.ssh/$PEM_NAME.pem $CLUSTER_NAME

./pass_aws_cred.sh ~/.ssh/$PEM_NAME.pem $CLUSTER_NAME

config/Hadoop/setup_cluster.sh ~/.ssh/$PEM_NAME.pem $CLUSTER_NAME
config/Hive/setup_cluster.sh ~/.ssh/$PEM_NAME.pem $CLUSTER_NAME

config/Spark/setup_cluster.sh ~/.ssh/$PEM_NAME.pem $CLUSTER_NAME

config/Zeppelin/setup_cluster.sh ~/.ssh/$PEM_NAME.pem $CLUSTER_NAME

config/Tachyon/setup_cluster.sh ~/.ssh/$PEM_NAME.pem $CLUSTER_NAME

./sparklab_create_cred.sh $PEM_NAME $CLUSTER_NAME

