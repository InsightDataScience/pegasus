#!/bin/bash

MEMINFO=($(free -m | sed -n '2p' | sed -e "s/[[:space:]]\+/ /g"))
TOTMEM=${MEMINFO[1]}
EXECMEM=$(echo "0.90 * ($TOTMEM - 1000)" | bc -l)

sudo chown -R ubuntu ~/

tmux new-session -s ipython_notebook -n bash -d

tmux send-keys -t ipython_notebook 'PYSPARK_DRIVER_PYTHON=ipython PYSPARK_DRIVER_PYTHON_OPTS="notebook --no-browser --ip="*" --port=8888" pyspark --packages com.databricks:spark-csv_2.10:1.1.0 --master spark://'$(hostname)':7077 --executor-memory '${EXECMEM%.*}'M --driver-memory '${EXECMEM%.*}'M --conf spark.hadoop.fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem' C-m
