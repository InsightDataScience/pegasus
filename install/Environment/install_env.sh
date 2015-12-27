#!/bin/bash

sudo apt-get update

sudo apt-get --yes --force-yes install ssh rsync openjdk-7-jdk scala python-dev python-pip python-numpy python-scipy python-pandas gfortran git supervisor ruby

# get sbt repository
wget https://dl.bintray.com/sbt/debian/sbt-0.13.7.deb -P ~/Downloads
sudo dpkg -i ~/Downloads/sbt-*

# get maven3 repository
sudo apt-get purge maven maven2 maven3
sudo apt-add-repository -y ppa:andrei-pozolotin/maven3
sudo apt-get update
sudo apt-get --yes --force-yes install maven3

sudo pip install nose seaborn boto scikit-learn "ipython[notebook]"

if ! grep "export JAVA_HOME" ~/.profile; then
  echo -e "\nexport JAVA_HOME=/usr" | cat >> ~/.profile
  echo -e "export PATH=\$PATH:\$JAVA_HOME/bin" | cat >> ~/.profile
fi
