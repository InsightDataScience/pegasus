## Automating AWS deployment

# 1. Install the boto package for python
This will allow you to programatically interface with your AWS account
```
$ sudo pip install boto
```
Create a .boto file in your home directory
```
$ touch ~/.boto
```
Insert the following into .boto with your AWS credentials. These credentials will be used to access you AWS cluster as well as AWS's S3 storage.
```
[Credentials]
aws_access_key_id = XXXXXX
aws_secret_access_key = XXXXX+XXXX
```

# 2. Clone repository
* Place in home folder
* Move into the ClusterUtilities/Devs folder
```
$ git clone https://github.com/InsightDataScience/ClusterUtilities.git
$ cd ClusterUtilities/Devs
```

# 3. Installation commands
Always run fetch_instances.py to get the instance IPs and hostnames for the next installation
```
python fetch_instances.py <region> <cluster-name>
```

## Zookeeper Installation
```
$ ./install_zookeeper.sh ~/.ssh/<personal.pem>
```

## Kafka Installation
Requires Zookeeper installation
```
$ ./install_kafka.sh ~/.ssh/<personal.pem>
```

## Spark with IPython Installation
Requires a distributed files system such as HDFS(Hadoop) or S3
```
$ ./install_spark.sh ~/.ssh/<personal.pem>
```

Go to **localhost:7777** on your machine to access the IPython Server on the Spark Master.

## Hadoop Installation
```
$ ./install_hadoop.sh ~/.ssh/<personal.pem>
```

## Pig Installation
Requires Hadoop installation
```
$ ./install_pig.sh ~/.ssh/<personal.pem>
```

## Elasticsearch Installation
```
$ ./install_elasticsearch.sh ~/.ssh/<personal.pem> <ec2-security-group>
```

## Cassandra Installation
```
$ ./install_cassandra.sh ~/.ssh/<personal.pem> <cassandra-cluster-name>
```
