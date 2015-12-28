#!/bin/bash

CLUSTER_NAME=test-cluster
REGION=us-west-2

./ec2spinup templates/instances/example.json

./ec2fetch $REGION $CLUSTER_NAME

./ec2install $CLUSTER_NAME environment
./ec2install $CLUSTER_NAME ssh
./ec2install $CLUSTER_NAME aws
./ec2install $CLUSTER_NAME hadoop
./ec2install $CLUSTER_NAME hive
./ec2install $CLUSTER_NAME pig
./ec2install $CLUSTER_NAME spark

