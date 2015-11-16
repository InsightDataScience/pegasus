## Project Pegasus - Automating AWS deployment

# 1. Install the boto package for python
This will allow you to programatically interface with your AWS account
```
$ sudo pip install boto
```
Add your AWS credentials to `~/.profile` and source it
```
export AWS_ACCESS_KEY_ID=XXXX
export AWS_SECRET_ACCESS_KEY=XXXX
```
```
$ . ~/.profile
```
# 2. Installation commands
Always run fetch_instances.py to get the instance IPs and hostnames for the next installation
```
python fetch_instances.py <region> <cluster-name>
```

## Passwordless SSH
```
$ SSH/setup_passwordless_ssh.sh <pem-key> <cluster-name>
```
## Environment/Packages on all machines
```
$ install/Env/install_env_cluster.sh <pem-key> <cluster-name>
```
## Hadoop installation
```
$ install/Hadoop/install_hadoop_cluster.sh <pem-key> <cluster-name>
$ config/Hadoop/setup_cluster.sh <pem-key> <cluster-name>
```
## Hive installation
```
$ install/Hive/install_Hive_cluster.sh <pem-key> <cluster-name>
$ config/Hive/setup_cluster.sh <pem-key> <cluster-name>
```
## Pig installation
```
$ install/Pig/install_Pig_cluster.sh <pem-key> <cluster-name>
```
## Spark installation
```
$ install/Spark/install_Spark_cluster.sh <pem-key> <cluster-name>
$ config/Spark/setup_cluster.sh <pem-key> <cluster-name>
```
## Zeppelin installation
```
$ install/Zeppelin/install_Zeppelin_cluster.sh <pem-key> <cluster-name>
$ config/Zeppelin/setup_cluster.sh <pem-key> <cluster-name>
```
## Tachyon installation
```
$ install/Tachyon/install_Tachyon_cluster.sh <pem-key> <cluster-name>
$ config/Tachyon/setup_cluster.sh <pem-key> <cluster-name>
```
## Zookeeper installation
```
$ install/Zookeeper/install_Zookeeper_cluster.sh <pem-key> <cluster-name>
$ config/Zookeeper/setup_cluster.sh <pem-key> <cluster-name>
```
## HBase installation
```
$ install/HBase/install_HBase_cluster.sh <pem-key> <cluster-name>
$ config/HBase/setup_cluster.sh <pem-key> <cluster-name>
```
## Kafka installation
```
$ install/Kafka/install_Kafka_cluster.sh <pem-key> <cluster-name>
$ config/Kafka/setup_cluster.sh <pem-key> <cluster-name>
```
## Elasticsearch installation
```
$ install/Elasticsearch/install_Elasticsearch_cluster.sh <pem-key> <cluster-name>
$ config/Elasticsearch/setup_cluster.sh <pem-key> <cluster-name>
```
## Kibana installation
```
$ install/Kibana/install_Kibana_cluster.sh <pem-key> <cluster-name>
$ config/Kibana/setup_cluster.sh <pem-key> <cluster-name>
```
## Cassandra installation
```
$ install/Cassandra/install_Cassandra_cluster.sh <pem-key> <cluster-name>
$ config/Cassandra/setup_cluster.sh <pem-key> <cluster-name>
```
