#!/bin/bash

PEG_ROOT=$(dirname ${BASH_SOURCE})/../..

CLUSTER_NAME=hadoop-cluster

peg up ${PEG_ROOT}/examples/hadoop/namenode.yml &
peg up ${PEG_ROOT}/examples/hadoop/datanodes.yml &

wait

peg fetch ${CLUSTER_NAME}

peg install ${CLUSTER_NAME} ssh
peg install ${CLUSTER_NAME} hadoop
