#!/bin/bash

GITHUB_USER=$1
GITHUB_PASSWORD=$2

git clone https://$GITHUB_USER:$GITHUB_PASSWORD@github.com/aouyang1/spark_tutorials.git

MEMINFO=($(free -m | sed -n '2p' | sed -e "s/[[:space:]]\+/ /g"))
TOTMEM=${MEMINFO[1]}
EXECMEM=$(echo "0.90 * ($TOTMEM - 1000)" | bc -l)

sudo chown -R ubuntu ~/

tmux new-session -s ipython_notebook -n bash -d

tmux send-keys -t ipython_notebook 'PYSPARK_DRIVER_PYTHON=ipython PYSPARK_DRIVER_PYTHON_OPTS="notebook --no-browser --port=7777" pyspark --packages com.databricks:spark-csv_2.10:1.1.0 --master spark://'$(hostname)':7077 --executor-memory '${EXECMEM%.*}'M --driver-memory '${EXECMEM%.*}'M' C-m
