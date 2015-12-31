#!/bin/bash

# must be called from the top level

# check input arguments
if [ "$#" -ne 2 ]; then
    echo "Please specify pem-key location and cluster name!" && exit 1
fi

# get input arguments [aws region, pem-key location]
PEMLOC=$1
INSTANCE_NAME=$2

# check if pem-key location is valid
if [ ! -f $PEMLOC ]; then
    echo "pem-key does not exist!" && exit 1
fi

# import AWS private DNS names
FIRST_LINE=true
while read line; do
    if [ "$FIRST_LINE" = true ]; then
        MASTER_NAME=$line
        SLAVE_NAME=()
        FIRST_LINE=false
    else
        SLAVE_NAME+=($line)
    fi
done < tmp/$INSTANCE_NAME/private_dns

# import AWS public DNS's
FIRST_LINE=true
while read line; do
    if [ "$FIRST_LINE" = true ]; then
        MASTER_DNS=$line
        SLAVE_DNS=()
        FIRST_LINE=false
    else
        SLAVE_DNS+=($line)
    fi
done < tmp/$INSTANCE_NAME/public_dns

# Configure base Hadoop master and slaves
ssh -o "StrictHostKeyChecking no" -i $PEMLOC ubuntu@$MASTER_DNS 'bash -s' < config/hadoop/setup_single.sh $MASTER_DNS &
for dns in "${SLAVE_DNS[@]}"
do
    ssh -o "StrictHostKeyChecking no" -i $PEMLOC ubuntu@$dns 'bash -s' < config/hadoop/setup_single.sh $MASTER_DNS &
done

wait

# Configure Hadoop master and slaves
ssh -i $PEMLOC ubuntu@$MASTER_DNS 'bash -s' < config/hadoop/config_hosts.sh $MASTER_DNS $MASTER_NAME "${SLAVE_DNS[@]}" "${SLAVE_NAME[@]}"
ssh -i $PEMLOC ubuntu@$MASTER_DNS 'bash -s' < config/hadoop/config_namenode.sh $MASTER_NAME "${SLAVE_NAME[@]}" &
for dns in "${SLAVE_DNS[@]}"
do
    ssh -i $PEMLOC ubuntu@$dns 'bash -s' < config/hadoop/config_datanode.sh &
done

wait

ssh -i $PEMLOC ubuntu@$MASTER_DNS '. ~/.profile; hdfs namenode -format'
ssh -i $PEMLOC ubuntu@$MASTER_DNS '. ~/.profile; $HADOOP_HOME/sbin/start-dfs.sh'
ssh -i $PEMLOC ubuntu@$MASTER_DNS '. ~/.profile; $HADOOP_HOME/sbin/start-yarn.sh'
ssh -i $PEMLOC ubuntu@$MASTER_DNS '. ~/.profile; $HADOOP_HOME/sbin/mr-jobhistory-daemon.sh start historyserver'

echo "Hadoop configuration complete!"
