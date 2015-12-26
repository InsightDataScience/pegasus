## Project pegasus - Flying in the Cloud with Automated AWS Deployment

# 1. Install all Python dependencies on your local machine
This will allow you to programatically interface with your AWS account
```
$ sudo pip install -e .
```
Installs the following Python packages
* boto3
* moto
* schema

Add your AWS credentials to `~/.bash_profile` and source it
```
export AWS_ACCESS_KEY_ID=XXXX
export AWS_SECRET_ACCESS_KEY=XXXX
```
```
$ . ~/.bash_profile
```
Install pytest and run tests from top directory
```
$ sudo pip install pytest
$ py.test
```
# 2. Spin up your cluster on AWS

* Use the Ubuntu Server 14.04 LTS (HVM), SSD Volume Type AMI
* To start we recommend deploying a 4 node cluster
* Tag each instance with the same name through the AWS EC2 console
  * e.g. test-cluster 

Or

Use ec2spinup to deploy a cluster from the command line
```
$ ./ec2spinup <instance-template-file>
```

The `instance-template-file` is simply a JSON file that ec2spinup uses. Within this file you will must specify the follow as shown:
```
{
    "purchase_type": "spot"|"on_demand",
    "region": "us-east-1"|"us-west-1"|"us-west-2"|"eu-central-1"|"eu-west-1"|"ap-southeast-1"|"ap-southeast-2"|"ap-northeast-1"|"sa-east-1",
    "subnet": "string",
    "image": "string",
    "price": "string",
    "num_instances": 4,
    "key_name": "string",
    "security_group_ids": [
        "string"
    ],
    "instance_type": "t1.micro"|"m1.small"|"m1.medium"|"m1.large"|"m1.xlarge"|"m3.medium"|"m3.large"|"m3.xlarge"|"m3.2xlarge"|"m4.large"|"m4.xlarge"|"m4.2xlarge"|"m4.4xlarge"|"m4.10xlarge"|"t2.micro"|"t2.small"|"t2.medium"|"t2.large"|"m2.xlarge"|"m2.2xlarge"|"m2.4xlarge"|"cr1.8xlarge"|"i2.xlarge'|"i2.2xlarge'|"i2.4xlarge"|"i2.8xlarge"|"hi1.4xlarge"|"hs1.8xlarge"|"c1.medium"|"c1.xlarge"|"c3.large"|"c3.xlarge"|"c3.2xlarge"|"c3.4xlarge"|"c3.8xlarge"|"c4.large"|"c4.xlarge"|"c4.2xlarge"|"c4.4xlarge"|"c4.8xlarge"|"cc1.4xlarge"|"cc2.8xlarge"|"g2.2xlarge"|"cg1.4xlarge"|"r3.large"|"r3.xlarge"|"r3.2xlarge"|"r3.4xlarge"|"r3.8xlarge"|"d2.xlarge"|"d2.2xlarge"|"d2.4xlarge"|"d2.8xlarge",
    "tag_name": "string"
    "vol_size": 100
}
```
* **purchase_type** (*string*) - choose between on-demand or spot instances
* **region** (*string*) - AWS region you wish to spin your cluster in
* **subnet** (*string*) - the VPC subnet id e.g. "subnet-61c12804"
* **image** (*string*) - the AMI id you would like to spin the instance up with e.g. "ami-df6a8b9b"
* **price** (*string*) - spot price you would like to set. Ignored if purchase type is "on_demand" e.g. "0.25"
* **num_instances** (*integer*) - number of instances to deploy
* **key_name** (*string*) - the pem key name to be used for all instances e.g. "insight-cluster"
* **security_group_ids** (*list*) - a list of the security group ids
  * (*string*) e.g. "sg-e9f17e8c"
* **instance_type** (*string*) - type of instances to deploy
* **tag_name** (*string*) - tag all your instances with this name e.g. "test-cluster"
* **vol_size** (*integer*) - size of the EBS volume in GB. Uses magnetic storage

# 3. Fetching AWS cluster DNS and hostname information
Once the nodes are up and running on AWS, we'll need to grab the DNS and hostname information about the cluster you wish to work with on your local machine

Always run `ec2fetch` to get the instance DNSs and hostnames before installation. DNSs and hostnames will be saved into the `tmp` folder under the specified cluster name as `public_dns` and `private_dns` respectively
```
$ ./ec2fetch <region> <cluster-name>
```
Under the tmp/`<cluster-name>` folder you will find the `public_dns` and `private_dns` files. The first record in each file is considered the Master node for any cluster technology that has a Master-Worker setup. 

*tmp/\<cluster-name\>/public_dns*
```
ec2-52-32-227-84.us-west-2.compute.amazonaws.com  **MASTER**
ec2-52-10-128-74.us-west-2.compute.amazonaws.com  **WORKER1**
ec2-52-35-15-97.us-west-2.compute.amazonaws.com   **WORKER2**
ec2-52-35-11-46.us-west-2.compute.amazonaws.com   **WORKER3**
```
*tmp/\<cluster-name\>/private_dns*
```
ip-172-31-38-105 **MASTER**
ip-172-31-39-193 **WORKER1**
ip-172-31-42-254 **WORKER2**
ip-172-31-44-133 **WORKER3**
```
Once the cluster IPs have been saved to the tmp folder, we can begin with installations. 
# 4. Setting up a newly provisioned AWS cluster
If this is a newly provisioned AWS cluster, always start with at least the following 3 steps in the following order before proceeding with other installations

1. **Environment/Packages on all machines** - installs base packages for python, java, scala on all nodes in the cluster
2. **Passwordless SSH** - enables passwordless SSH from your computer to the MASTER and the MASTER to all the WORKERS
3. **AWS Credentials** - places AWS keys onto all machines
```
$ ./ec2install <cluster-name> environment
$ ./ec2install <cluster-name> ssh
$ ./ec2install <cluster-name> aws
```

Depending on what you decide to install in the environment step, the process could take anywhere from 10-30 minutes. If you wish to speed this up, we recommend that you bake an AMI using [Packer](https://www.packer.io/) and the environment installation script. This will cut down the time to spin up a new cluster significantly. Some examples are shown in the packer folder.

When you use the `ec2spinup` script, you will need to change the instance JSON template to use the new AMI instead of the base Ubuntu 14.04 Trusty AMI

# 5. Start installing!
```
$ ./ec2install <cluster-name> <technology>
```
The `technology` tag can be any of the following:
* hadoop
* hive
  * requires hadoop
* pig
  * requires hadoop
* spark
* zeppelin
* tachyon
* zookeeper
* hbase
  * requires hadoop, zookeeper
* kafka
  * requires zookeeper
* elasticsearch
* kibana
  * requires elasticsearch
* cassandra
* opscenter
  * requires cassandra

# 6. Terminate a cluster
Tears down an on-demand or spot cluster on AWS
```
$ ./ec2terminate <region> <cluster-name>
```

# 7. Deployment Pipelines
If you'd like to automate this deployment process completely, you can write your own scripts. An example has been provided in the `templates/pipelines/spark_hadoop.sh` file.

Here it shows how we can spin up a 4 node cluster (ec2spinup) using the `example.json` instance template, grab the cluster information (ec2fetch) and install all the technologies (ec2install) in one script. We can deploy this cluster simply by running the following:
```
$ templates/pipelines/spark_hadoop.sh
```
```
#!/bin/bash

CLUSTER_NAME=test-cluster
REGION=us-west-2

./ec2spinup templates/instances/example.json

./ec2fetch $REGION $CLUSTER_NAME

./ec2install $CLUSTER_NAME environment
./ec2install $CLUSTER_NAME ssh
./ec2install $CLUSTER_NAME aws
./ec2install $CLUSTER_NAME hadoop
./ec2install $CLUSTER_NAME hive
./ec2install $CLUSTER_NAME pig
./ec2install $CLUSTER_NAME spark
```
