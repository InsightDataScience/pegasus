#!/bin/bash

. ~/.profile

tmux new-session -s supervisor -n bash -d
tmux send-keys -t supervisor '$STORM_HOME/bin/storm supervisor' C-m

