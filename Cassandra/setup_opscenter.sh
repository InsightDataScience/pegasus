#!/bin/bash

INTERFACE=$1

sudo apt-get update

mkdir ~/Downloads

curl -L http://downloads.datastax.com/community/opscenter.tar.gz | tar xz -C ~/Downloads

sudo mv ~/Downloads/opscenter-* /usr/local/opscenter

sed -i 's@interface = 0.0.0.0@interface = '"$INTERFACE"'@g' /usr/local/opscenter/conf/opscenterd.conf

/usr/local/opscenter/bin/opscenter
