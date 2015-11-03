#!/bin/bash

sudo apt-get update

wget http://apache.mesi.com.ar/hive/stable/apache-hive-1.2.0-bin.tar.gz -P ~/Downloads

sudo tar zxvf ~/Downloads/apache-hive-*.tar.gz -C /usr/local
sudo mv /usr/local/apache-hive-* /usr/local/hive
sudo mv /usr/local/hadoop/share/hadoop/yarn/lib/jline-* /usr/local/hadoop/share/hadoop/yarn/lib/jline.backup

echo -e "\nexport HIVE_HOME=/usr/local/hive\nexport PATH=\$PATH:\$HIVE_HOME/bin\n" | cat >> ~/.profile

. ~/.profile

hdfs dfs -mkdir /tmp
hdfs dfs -mkdir -p /user/hive/warehouse
hdfs dfs -chmod g+w /tmp
hdfs dfs -chmod g+w /user/hive/warehouse
