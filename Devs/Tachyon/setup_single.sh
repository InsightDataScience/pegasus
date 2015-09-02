#!/bin/bash

MASTER_HOSTNAME=$1; shift
WORKER_HOSTNAMES=( "$@" )

sudo apt-get update

sudo apt-get --yes --force-yes install openjdk-7-jdk

wget https://github.com/amplab/tachyon/releases/download/v0.7.1/tachyon-0.7.1-bin.tar.gz -P ~/Downloads
sudo tar zxvf ~/Downloads/tachyon-* -C /usr/local
sudo mv /usr/local/tachyon-* /usr/local/tachyon

sudo chown -R ubuntu /usr/local/tachyon

echo -e "\nexport TACHYON_HOME=/usr/local/tachyon\nexport PATH=\$PATH:\$TACHYON_HOME/bin" | cat >> ~/.profile
. ~/.profile

cp $TACHYON_HOME/conf/tachyon-env.sh.template $TACHYON_HOME/conf/tachyon-env.sh
sed -i 's@TACHYON_MASTER_ADDRESS=localhost@TACHYON_MASTER_ADDRESS='"$MASTER_HOSTNAME"'@g' $TACHYON_HOME/conf/tachyon-env.sh

mv $TACHYON_HOME/conf/workers $TACHYON_HOME/conf/workers.backup
for worker in ${WORKER_HOSTNAMES[@]}
do
    echo $worker >> $TACHYON_HOME/conf/workers
done

