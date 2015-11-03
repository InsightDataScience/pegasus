#!/bin/bash

git clone https://github.com/apache/incubator-zeppelin.git
sudo mv incubator-zeppelin /usr/local
sudo mv /usr/local/incubator-zeppelin /usr/local/zeppelin

echo -e "\nexport ZEPPELIN_HOME=/usr/local/zeppelin" | cat >> ~/.profile
echo -e "\nexport PATH=\$PATH:\$ZEPPELIN_HOME/bin" | cat >> ~/.profile
. ~/.profile

cp $ZEPPELIN_HOME/conf/zeppelin-env.sh.template $ZEPPELIN_HOME/conf/zeppelin-env.sh

sudo chown -R ubuntu $ZEPPELIN_HOME

sed -i '18i export JAVA_HOME=/usr' $ZEPPELIN_HOME/conf/zeppelin-env.sh
sed -i '18i export MASTER=spark://'$(hostname)':7077' $ZEPPELIN_HOME/conf/zeppelin-env.sh
sed -i '18i export SPARK_HOME='$SPARK_HOME'' $ZEPPELIN_HOME/conf/zeppelin-env.sh

MEMINFO=($(free -m | sed -n '2p' | sed -e "s/[[:space:]]\+/ /g"))
TOTMEM=${MEMINFO[1]}
EXECMEM=$(echo "0.90 * ($TOTMEM - 1000)" | bc -l)
#sed -i '18i export SPARK_SUBMIT_OPTIONS="--driver-memory '${EXECMEM%.*}'M --executor-memory '${EXECMEM%.*}'M"' $ZEPPELIN_HOME/conf/zeppelin-env.sh

sed -i 's@<value>8080</value>@<value>7888</value>@g' $ZEPPELIN_HOME/conf/zeppelin-site.xml

cd $ZEPPELIN_HOME
sudo mvn clean package -Pspark-1.5 -Dhadoop.version=2.2.0 -Phadoop-2.2 -DskipTests

zeppelin-daemon.sh start
