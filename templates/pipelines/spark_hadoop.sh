#!/bin/bash

CLUSTER_NAME=test-cluster
PEM_KEY_LOC=~/.ssh/insight-cluster3.pem

./spin_up templates/instances/example.json

./ec2fetch us-west-1 $CLUSTER_NAME

./ec2install $PEM_KEY_LOC $CLUSTER_NAME environment
./ec2install $PEM_KEY_LOC $CLUSTER_NAME ssh
./ec2install $PEM_KEY_LOC $CLUSTER_NAME aws
./ec2install $PEM_KEY_LOC $CLUSTER_NAME hadoop
./ec2install $PEM_KEY_LOC $CLUSTER_NAME hive
./ec2install $PEM_KEY_LOC $CLUSTER_NAME pig
./ec2install $PEM_KEY_LOC $CLUSTER_NAME spark

