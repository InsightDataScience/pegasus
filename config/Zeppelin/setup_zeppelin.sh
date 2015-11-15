#!/bin/bash

. ~/.profile

cp $ZEPPELIN_HOME/conf/zeppelin-env.sh.template $ZEPPELIN_HOME/conf/zeppelin-env.sh
cp $ZEPPELIN_HOME/conf/zeppelin-site.xml.template $ZEPPELIN_HOME/conf/zeppelin-site.xml

sed -i '18i export JAVA_HOME=/usr' $ZEPPELIN_HOME/conf/zeppelin-env.sh
sed -i '18i export MASTER=spark://'$(hostname)':7077' $ZEPPELIN_HOME/conf/zeppelin-env.sh
sed -i '18i export SPARK_HOME='$SPARK_HOME'' $ZEPPELIN_HOME/conf/zeppelin-env.sh

MEMINFO=($(free -m | sed -n '2p' | sed -e "s/[[:space:]]\+/ /g"))
TOTMEM=${MEMINFO[1]}
EXECMEM=$(echo "0.90 * ($TOTMEM - 1000)" | bc -l)
#sed -i '18i export SPARK_SUBMIT_OPTIONS="--driver-memory '${EXECMEM%.*}'M --executor-memory '${EXECMEM%.*}'M"' $ZEPPELIN_HOME/conf/zeppelin-env.sh

sed -i 's@<value>8080</value>@<value>7888</value>@g' $ZEPPELIN_HOME/conf/zeppelin-site.xml

tmux new-session -s zeppelin_notebook -n bash -d

tmux send-keys -t zeppelin_notebook '. ~/.profile; zeppelin-daemon.sh start' C-m
