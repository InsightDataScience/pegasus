#!/bin/bash

# check input arguments
if [ "$#" -ne 4 ]; then
    echo "Please specify pem-key location, cluster name, AWS access key ID, and AWS secret access key!" && exit 1
fi

PEMLOC=$1
INSTANCE_NAME=$2
AWS_ACCESS_KEY_ID=$3
AWS_SECRET_ACCESS_KEY=$4

ssh -o "StrictHostKeyChecking no" -i $PEMLOC ubuntu@$(head -n 1 $INSTANCE_NAME/public_dns) 'bash -s' < Spark/setup_ipython.sh $AWS_ACCESS_KEY_ID $AWS_SECRET_ACCESS_KEY

sleep 3

ssh -N -f -L localhost:7777:localhost:7777 ubuntu@$(head -n 1 $INSTANCE_NAME/public_dns)

echo "IPython server is running at localhost:7777!"

