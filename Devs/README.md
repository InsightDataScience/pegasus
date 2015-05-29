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
# 2. Spin up AWS Instances
![AWSConsole] (/images/AWSConsole.png)
![EC2Dashboard] (/images/EC2Dashboard.png)
![ChooseAMI] (/images/ChooseAMI.png)
![ChooseInstance] (/images/ChooseInstance.png)
![InstanceDetails] (/images/InstanceDetails.png)

## Nothing here needs changing unless you wish to change the default storage size per instance
![AddStorage] (/images/AddStorage.png)

## Give a unique name for your instances otherwise they'll be lost among your other instances
![TagInstance] (/images/TagInstance.png)

## Setting the security settings to be completely open is not recommended for production, but is simpler for testing purposes
![SecurityGroup] (/images/SecurityGroup.png)

Save your AWS .pem key to ~/.ssh
* Create one if you don't have one associated with your AWS account
* Change permissions for the pem-key
```
$ chmod 600 ~/.ssh/<personal.pem>
```
# 3. Clone repository
* Place in home folder
* Move into the ClusterUtilities/Devs folder
```
$ git clone https://github.com/InsightDataScience/ClusterUtilities.git
$ cd ClusterUtilities/Devs
```

# 4. Installation commands
## Zookeeper Installation
```
$ ./install_zookeeper.sh ~/.ssh/<personal.pem> <region> <cluster-name>
```

## Kafka Installation
Requires Zookeeper installation
```
$ ./install_kafka.sh ~/.ssh/<personal.pem> <region> <cluster-name>
```

## Spark with IPython Installation
Requires a distributed files system such as HDFS(Hadoop) or S3
```
$ ./install_spark.sh ~/.ssh/<personal.pem> <region> <cluster-name>
```

Go to **localhost:7777** on your machine to access the IPython Server on the Spark Master.

## Hadoop Installation
```
$ ./install_hadoop.sh ~/.ssh/<personal.pem> <region> <cluster-name>
```
You will need to SSH into the Namenode and start Hadoop after installation
```
$ $HADOOP_HOME/sbin/start-dfs.sh
$ $HADOOP_HOME/sbin/start-yarn.sh
$ $HADOOP_HOME/sbin/mr-jobhistory-daemon.sh start historyserver
```

## Pig Installation
Requires Hadoop installation
```
$ ./install_pig.sh ~/.ssh/<personal.pem> <region> <cluster-name>
```

## Elasticsearch Installation
```
$ ./install_elasticsearch.sh ~/.ssh/<personal.pem> <region> <cluster-name> <ec2-security-group>
```

## Cassandra Installation
```
$ ./install_cassandra.sh ~/.ssh/<personal.pem> <region> <cluster-name> <cassandra-cluster-name>
```
