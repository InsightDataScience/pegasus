#!/bin/bash

. ~/.profile

PRESTO_VER=$(head -n 1 $PRESTO_HOME/tech_ver.txt)

wget https://repo1.maven.org/maven2/com/facebook/presto/presto-cli/$PRESTO_VER/presto-cli-$PRESTO_VER-executable.jar -P ~/Downloads

mv ~/Downloads/presto-cli* ~/Downloads/presto
chmod +x ~/Downloads/presto
sudo mv ~/Downloads/presto /usr/bin/
