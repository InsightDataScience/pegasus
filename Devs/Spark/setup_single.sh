#!/bin/bash

sudo apt-get update

sudo apt-get --yes --force-yes install openjdk-7-jdk scala python-dev python-pip python-numpy python-scipy gfortran

sudo pip install nose

sudo easy_install pymc

wget https://dl.bintray.com/sbt/debian/sbt-0.13.7.deb -P ~/Downloads
sudo dpkg -i ~/Downloads/sbt-*
sudo apt-get install sbt

wget http://mirror.reverse.net/pub/apache/spark/spark-1.4.1/spark-1.4.1-bin-hadoop2.4.tgz -P ~/Downloads
sudo tar zxvf ~/Downloads/spark-* -C /usr/local
sudo mv /usr/local/spark-* /usr/local/spark
sudo chown -R ubuntu /usr/local/spark

echo -e "\nexport SPARK_HOME=/usr/local/spark\nexport PATH=\$PATH:\$SPARK_HOME/bin" | cat >> ~/.profile
. ~/.profile

cp $SPARK_HOME/conf/spark-env.sh.template $SPARK_HOME/conf/spark-env.sh
sed -i '6i export JAVA_HOME=/usr' $SPARK_HOME/conf/spark-env.sh
sed -i '7i export SPARK_PUBLIC_DNS="'$1'"' $SPARK_HOME/conf/spark-env.sh
