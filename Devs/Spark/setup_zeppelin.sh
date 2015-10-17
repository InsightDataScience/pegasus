#!/bin/bash

sudo apt-get purge maven maven2 maven3
sudo apt-add-repository ppa:andrei-pozolotin/maven3
sudo apt-get update

sudo apt-get --yes --force-yes install maven3

git clone https://github.com/apache/incubator-zeppelin.git
mkdir /usr/local/zeppelin
mv incubator-zeppelin /usr/local/zeppelin

echo -e "\nexport ZEPPELIN_HOME=/usr/local/zeppelin" | cat >> ~/.profile
. ~/.profile

cd $ZEPPELIN_HOME
sudo mvn clean package -Pspark-1.5 -Dhadoop.version=2.2.0 -Phadoop-2.2 -DskipTests

cp $ZEPPELIN_HOMEi/conf/zeppelin-env.sh.template $ZEPPELIN_HOME/conf/zeppelin-env.sh
cp $ZEPPELIN_HOME/conf/zeppelin-site.xml.template $ZEPPELIN_HOME/conf/zeppelin-site.xml

sed -i '18i export JAVA_HOME=/usr' $ZEPPELIN_HOME/conf/zeppelin-env.sh
sed -i '18i export MASTER=spark://'$MASTER_NAME':7077' $ZEPPELIN_HOME/conf/zeppelin-env.sh
sed -i '18i export SPARK_HOME='$SPARK_HOME'' $ZEPPELIN_HOME/conf/zeppelin-env.sh

MEMINFO=($(free -m | sed -n '2p' | sed -e "s/[[:space:]]\+/ /g"))
TOTMEM=${MEMINFO[1]}
EXECMEM=$(echo "0.90 * ($TOTMEM - 1000)" | bc -l)
sed -i '18i export SPARK_SUBMIT_OPTIONS="--driver-memory '${EXECMEM%.*}'M --executor-memory '${EXECMEM%.*}'M"' $ZEPPELIN_HOME/conf/zeppelin-env.sh

sed -i 's@<value>8080</value>@<value>7888</value>@g' $ZEPPELIN_HOME/conf/zeppelin-env.sh


tmux new-session -s zeppelin_notebook -n bash -d

tmux send-keys -t zeppelin_notebook 'bin/zeppelin-daemon.sh start' C-m
