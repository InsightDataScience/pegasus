#!/bin/bash

PEM_NAME=$1
INSTANCE_NAME=$2

cp ~/.ssh/$PEM_NAME.pem spark_lab.sh $INSTANCE_NAME
head -n 1 $INSTANCE_NAME/public_dns > $INSTANCE_NAME/master_public_dns.txt
tar zcvf $INSTANCE_NAME.tar.gz $INSTANCE_NAME
mv $INSTANCE_NAME $INSTANCE_NAME.tar.gz DataLabs

