#!/bin/bash

# must be called from top level

PEMLOC=./*.pem
IP=$(cat master_public_dns.txt)

ssh -N -f -L localhost:8888:localhost:7777 -o "StrictHostKeyChecking no" -i $PEMLOC ubuntu@$IP

echo "You can access your Spark cluster's IPython notebook at localhost:8888."
echo "Monitor your Spark Applications at "$IP":8080."
echo "Monitor your Spark Jobs at "$IP":4040." 
