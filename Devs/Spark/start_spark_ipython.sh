#!/bin/bash

# check input arguments
if [ "$#" -ne 3 ]; then
    echo "Please specify pem-key location, AWS access key ID, and AWS secret access key!" && exit 1
fi

PEMLOC=$1
AWS_ACCESS_KEY_ID=$2
AWS_SECRET_ACCESS_KEY=$3

ssh -o "StrictHostKeyChecking no" -i $PEMLOC ubuntu@$(head -n 1 ../public_dns) 'bash -s' < setup_ipython.sh $AWS_ACCESS_KEY_ID $AWS_SECRET_ACCESS_KEY

sleep 3

ssh -N -f -L localhost:7777:localhost:7777 ubuntu@$(head -n 1 ../public_dns)

echo "IPython server is running at localhost:7777!"

