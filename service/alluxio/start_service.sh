#!/bin/bash

# must be called from the top level

# check input arguments
if [ "$#" -ne 2 ]; then
    echo "Please specify pem-key location!" && exit 1
fi

# get input arguments [aws region, pem-key location]
PEMLOC=$1
INSTANCE_NAME=$2

# check if pem-key location is valid
if [ ! -f $PEMLOC ]; then
    echo "pem-key does not exist!" && exit 1
fi

# import AWS public DNS's
NODE_DNS=()
while read line; do
    NODE_DNS+=($line)
done < tmp/$INSTANCE_NAME/public_dns

cnt=0
for dns in ${NODE_DNS[@]}; do
  if [ $cnt == 0 ]; then
    ssh -i $PEMLOC ubuntu@${dns} '. ~/.profile; /usr/local/alluxio/bin/alluxio-start.sh master'
  else
    ssh -i $PEMLOC ubuntu@${dns} '. ~/.profile; /usr/local/alluxio/bin/alluxio-start.sh worker SudoMount'
  fi
  cnt=$(($cnt+1))
done

echo "Alluxio Started!"
