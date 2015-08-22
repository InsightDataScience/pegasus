# This script runs camus which is a distributed consumer to save messages from Kafka to HDFS
# The topics to be consumed can be white listed in the camus.properties file and the topics could be black listed too
# This scripts changes the path to hadoop's path and runs the camus jar in that path
#!/usr/bin/env bash

cd /usr/local/hadoop/etc/hadoop/
hadoop jar camus-example-0.1.0-SNAPSHOT-shaded.jar com.linkedin.camus.etl.kafka.CamusJob -P ~/ronak/camus/camus-example/src/main/resources/camus.properties
