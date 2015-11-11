#!/bin/bash

PIG_VER=0.15.0

if [ ! -f ~/Downloads/pig-$PIG_VER.tar.gz ]; then
  wget http://apache.mirrorcatalogs.com/pig/latest/pig-$PIG_VER.tar.gz -P ~/Downloads
  sudo tar -zxvf ~/Downloads/pig-*.tar.gz -C /usr/local
  sudo mv /usr/local/pig-* /usr/local/pig
fi

if ! grep "export PIG_HOME" ~/.profile; then
  echo -e "\nexport PIG_HOME=/usr/local/pig\nexport PATH=\$PATH:\$PIG_HOME/bin" | cat >> ~/.profile

  . ~/.profile
fi
