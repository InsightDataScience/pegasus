#!/bin/bash

curl -L http://downloads.datastax.com/community/opscenter.tar.gz | tar xz -C ~/Downloads

sudo mv ~/Downloads/opscenter-* /usr/local/opscenter

echo -e "\nexport OPSCENTER_HOME=/usr/local/opscenter" >> ~/.profile

. ~/.profile

sudo chown -R ubuntu $OPSCENTER_HOME
