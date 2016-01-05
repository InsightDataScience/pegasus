#!/bin/bash

. ~/.profile

tmux new-session -s nimbus -n bash -d
tmux send-keys -t nimbus '$STORM_HOME/bin/storm nimbus' C-m

tmux new-session -s stormui -n bash -d
tmux send-keys -t stormui '$STORM_HOME/bin/storm ui' C-m
