#!/bin/bash
. ~/.profile

# config.properties
cat >> $PRESTO_HOME/etc/config.properties << EOL
coordinator=true
node-scheduler.include-coordinator=false
discovery-server.enabled=true
EOL


