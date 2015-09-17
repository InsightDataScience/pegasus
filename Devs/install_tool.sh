#!/bin/bash

# first input argument should be technology to install
if [ "$#" -lt 2 ]; then
    echo "Please specify technology to install and the AWS pem key location"
    echo "e.g. $ ./install_tool cassandra ~/.ssh/insight-cluster.pem" && exit 1
fi

TECHNOLOGY=$1; shift
PEMLOC=$1

if [ $TECHNOLOGY == "zookeeper" ]; then
    echo "Installing Zookeeper..."
else
    echo "Technology "$TECHNOLOGY" not found!!!"
fi
