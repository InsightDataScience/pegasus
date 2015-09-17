#!/bin/bash

# must be called from top level

# check input arguments
if [ "$#" -ne 2 ]; then
    echo "Please specify pem-key location and the public IP!" && exit 1
fi

# get input arguments [pem-key location]
PEMLOC=$1
IP=$2

# Enable passwordless SSH from local to master
if ! [ -f ~/.ssh/id_rsa ]; then
    ssh-keygen -f ~/.ssh/id_rsa -t rsa -P ""
fi

KEY=$(cat ~/.ssh/id_rsa.pub) ssh -o "StrictHostKeyChecking no" -i $PEMLOC ubuntu@$IP 'if grep -Fxq "$KEY" ~/.ssh/authorized_keys; then echo $KEY >> ~/.ssh/authorized_keys; echo passwordless SSH enabled.; fi;'

ssh -N -f -L localhost:7778:localhost:7777 ubuntu@$IP

echo "You can access your Spark cluster's IPython notebook at localhost:7778."
