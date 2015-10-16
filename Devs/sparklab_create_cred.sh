#!/bin/bash

PEM_NAME=$1
INSTANCE_NAME=$2

cp ~/.ssh/$PEM_NAME.pem sparklab.sh tmp/$INSTANCE_NAME
head -n 1 tmp/$INSTANCE_NAME/public_dns > tmp/$INSTANCE_NAME/master_public_dns.txt
tar zcvf tmp/$INSTANCE_NAME.tar.gz tmp/$INSTANCE_NAME
cp tmp/$INSTANCE_NAME.tar.gz DataLabs

