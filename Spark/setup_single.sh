#!/bin/bash

. ~/.profile

cp $SPARK_HOME/conf/spark-env.sh.template $SPARK_HOME/conf/spark-env.sh

OVERSUBSCRIPTION_FACTOR=3
WORKER_CORES=$(echo "$(nproc)*$OVERSUBSCRIPTION_FACTOR" | bc)
sed -i '6i export JAVA_HOME=/usr' $SPARK_HOME/conf/spark-env.sh
sed -i '7i export SPARK_PUBLIC_DNS="'$1'"' $SPARK_HOME/conf/spark-env.sh
sed -i '8i export SPARK_WORKER_CORES='$WORKER_CORES'' $SPARK_HOME/conf/spark-env.sh
