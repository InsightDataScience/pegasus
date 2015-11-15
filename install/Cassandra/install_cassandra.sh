#!/bin/bash

curl -L http://downloads.datastax.com/community/dsc.tar.gz | tar xz -C ~/Downloads

sudo mv ~/Downloads/dsc-cassandra-* /usr/local/cassandra

echo -e "\nexport CASSANDRA_HOME=/usr/local/cassandra\nexport PATH=\$PATH:\$CASSANDRA_HOME/bin" >> ~/.profile

. ~/.profile

sudo chown -R ubuntu $CASSANDRA_HOME
