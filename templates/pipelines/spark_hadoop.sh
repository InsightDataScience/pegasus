#!/bin/bash

CLUSTER_NAME=test-cluster

peg up templates/instances/example.yml

peg fetch $CLUSTER_NAME

peg install $CLUSTER_NAME ssh
peg install $CLUSTER_NAME aws
peg install $CLUSTER_NAME hadoop
peg install $CLUSTER_NAME hive
peg install $CLUSTER_NAME pig
peg install $CLUSTER_NAME spark

