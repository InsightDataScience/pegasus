#!/bin/bash

TACHYON_VER=0.7.1

if [ ! -f ~/Downloads/tachyon-$TACHYON_VER-bin.tar.gz ]; then
  wget https://github.com/amplab/tachyon/releases/download/v$TACHYON_VER/tachyon-$TACHYON_VER-bin.tar.gz -P ~/Downloads
  sudo tar zxvf ~/Downloads/tachyon-* -C /usr/local
  sudo mv /usr/local/tachyon-* /usr/local/tachyon

  sudo chown -R ubuntu /usr/local/tachyon
fi

if ! grep "export TACHYON_HOME" ~/.profile; then
  echo -e "\nexport TACHYON_HOME=/usr/local/tachyon\nexport PATH=\$PATH:\$TACHYON_HOME/bin" | cat >> ~/.profile
  . ~/.profile
fi
