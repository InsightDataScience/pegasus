#!/bin/bash

# check input arguments
if [ "$#" -ne 1 ]; then
    echo "Please specify the pem-key location" && exit 1
fi

PEMLOC=$1

# check if pem-key location is valid
if [ ! -f $PEMLOC ]; then
    echo "pem-key does not exist!" && exit 1
fi

MASTER_DNS=$(sed -n '1p' public_dns)

ssh -i $PEMLOC ubuntu@$MASTER_DNS 'bash -s' < Pig/setup_pig.sh

