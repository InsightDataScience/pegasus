#!/bin/bash

SLAVE_DNS=( "$@" )
           
sudo apt-get update 
sudo apt-get --yes --force-yes install ssh rsync

if ! [ -f ~/.ssh/id_rsa ]; then
    ssh-keygen -f ~/.ssh/id_rsa -t rsa -P ""
fi
sudo cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys

# copy id_rsa.pub in master to all slaves authorized_keys for passwordless ssh
# add additional for multiple slaves
for dns in ${SLAVE_DNS[@]}
do
    echo "Adding $DNS to authorized keys..."
    cat ~/.ssh/id_rsa.pub | ssh -o "StrictHostKeyChecking no" -i ~/.ssh/*.pem ubuntu@$dns 'cat >> ~/.ssh/authorized_keys'
done
