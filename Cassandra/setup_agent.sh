#!/bin/bash

STOMP_INTERFACE=$1

sudo apt-get update

mkdir ~/Downloads

curl -L http://downloads.datastax.com/community/datastax-agent.tar.gz | tar xz -C ~/Downloads

sudo mv ~/Downloads/datastax-agent-* /usr/local/datastax-agent

touch address.yaml

echo -e "stomp_interface: $STOMP_INTERFACE" | cat >>  address.yaml

sudo mv address.yaml /usr/local/datastax-agent

/usr/local/datastax-agent/bin/datastax-agent


