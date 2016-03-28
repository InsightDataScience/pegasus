#!/bin/bash

. ~/.profile

cp ${HADOOP_HOME}/share/hadoop/tools/lib/aws-java-sdk-*.jar ${SPARK_HOME}/lib
cp ${HADOOP_HOME}/share/hadoop/tools/lib/hadoop-aws-*.jar ${SPARK_HOME}/lib

cp ${SPARK_HOME}/conf/spark-env.sh.template ${SPARK_HOME}/conf/spark-env.sh
cp ${SPARK_HOME}/conf/spark-defaults.conf.template ${SPARK_HOME}/conf/spark-defaults.conf

# configure spark-env.sh
OVERSUBSCRIPTION_FACTOR=3
WORKER_CORES=$(echo "$(nproc)*${OVERSUBSCRIPTION_FACTOR}" | bc)
sed -i '6i export JAVA_HOME=/usr' ${SPARK_HOME}/conf/spark-env.sh
sed -i '7i export SPARK_PUBLIC_DNS="'$1'"' ${SPARK_HOME}/conf/spark-env.sh
sed -i '8i export SPARK_WORKER_CORES='${WORKER_CORES}'' ${SPARK_HOME}/conf/spark-env.sh
sed -i '9i export DEFAULT_HADOOP_HOME='${HADOOP_HOME}'' ${SPARK_HOME}/conf/spark-env.sh


# configure spark-defaults.conf
hadoop_aws_jar=$(find /usr/local/spark/lib -type f | grep hadoop-aws)
aws_java_sdk_jar=$(find /usr/local/spark/lib -type f | grep aws-java-sdk)
sed -i '21i spark.hadoop.fs.s3a.impl org.apache.hadoop.fs.s3a.S3AFileSystem' ${SPARK_HOME}/conf/spark-defaults.conf
sed -i '22i spark.executor.extraClassPath '"${aws_java_sdk_jar}"':'"${hadoop_aws_jar}"'' ${SPARK_HOME}/conf/spark-defaults.conf
sed -i '23i spark.driver.extraClassPath '"${aws_java_sdk_jar}"':'"${hadoop_aws_jar}"'' ${SPARK_HOME}/conf/spark-defaults.conf
