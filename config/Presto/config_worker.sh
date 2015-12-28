#!/bin/bash
. ~/.profile

# config.properties
cat >> $PRESTO_HOME/etc/config.properties << EOL
coordinator=false
EOL

