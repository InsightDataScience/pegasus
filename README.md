## Project Pegasus - Flying in the Cloud with Automated AWS Deployment

This project enables anyone with an Amazon Web Services ([AWS] (http://aws.amazon.com/)) account to quickly deploy a number of distributed technologies all from their laptop or personal computer. The installation is fairly basic and should not be used for production. The purpose of this project is to enable fast protoyping of various distributed data pipelines and also help others explore distributed technologies without the headache of installing them.

We want to continue improving this tool by adding more features and other installations, so send us your pull requests or suggestions!

# Table of Contents
1. [Install Pegasus on your local machine](README.md#1-install-pegasus-on-your-local-machine)
2. [Spin up your cluster on AWS](README.md#2-spin-up-your-cluster-on-aws)
3. [Fetching AWS cluster DNS and hostname information](README.md#3-fetching-aws-cluster-dns-and-hostname-information)
4. [Setting up a newly provisioned AWS cluster](README.md#4-setting-up-a-newly-provisioned-aws-cluster)
5. [Start installing!](README.md#5-start-installing)
6. [Terminate a cluster](README.md#6-terminate-a-cluster)
7. [Deployment Pipelines](README.md#7-deployment-pipelines)

# 1. Install Pegasus on your local machine

This will allow you to programatically interface with your AWS account

Clone the Pegasus project to your local computer and install Python dependencies (**Python 2.7+ required**)
```bash
$ git clone https://github.com/InsightDataScience/pegasus.git
$ cd pegasus
$ sudo pip install -r requirements.txt
```
Installs the following Python packages
* boto3==1.2.2
* moto==0.4.19
* schema==0.4.0

Add your AWS credentials to `~/.bash_profile`, choose a default AWS region and source it
```bash
export AWS_ACCESS_KEY_ID=XXXX
export AWS_SECRET_ACCESS_KEY=XXXX
export AWS_DEFAULT_REGION=us-east-1|us-west-1|us-west-2|eu-central-1|eu-west-1|ap-southeast-1|ap-southeast-2|ap-northeast-1|sa-east-1
```
```bash
$ . ~/.bash_profile
```

You can test your boto3 AWS access by querying for the available regions for your AWS account:
```python
>>> import boto3
>>> client = boto3.client('ec2')
>>> client.describe_regions()
{u'Regions': [{u'Endpoint': 'ec2.eu-west-1.amazonaws.com',
   u'RegionName': 'eu-west-1'},
  {u'Endpoint': 'ec2.ap-southeast-1.amazonaws.com',
   u'RegionName': 'ap-southeast-1'},
  {u'Endpoint': 'ec2.ap-southeast-2.amazonaws.com',
   u'RegionName': 'ap-southeast-2'},
  {u'Endpoint': 'ec2.eu-central-1.amazonaws.com',
   u'RegionName': 'eu-central-1'},
  {u'Endpoint': 'ec2.ap-northeast-1.amazonaws.com',
   u'RegionName': 'ap-northeast-1'},
  {u'Endpoint': 'ec2.us-east-1.amazonaws.com', u'RegionName': 'us-east-1'},
  {u'Endpoint': 'ec2.sa-east-1.amazonaws.com', u'RegionName': 'sa-east-1'},
  {u'Endpoint': 'ec2.us-west-1.amazonaws.com', u'RegionName': 'us-west-1'},
  {u'Endpoint': 'ec2.us-west-2.amazonaws.com', u'RegionName': 'us-west-2'}],
 'ResponseMetadata': {'HTTPStatusCode': 200,
  'RequestId': '8949dfbe-63ab-4c0f-ba56-f9cd946de2ed'}}
```
Install [pytest] (http://pytest.org/latest/) and run tests from top directory
```bash
$ sudo pip install pytest
$ cd /path/to/pegasus
$ export PYTHONPATH=$(pwd)
$ py.test
```

# 2. Spin up your cluster on AWS

Currently all installations only work with the Ubuntu Server 14.04 LTS (HVM) AMI.

* Use the Ubuntu Server 14.04 LTS (HVM), SSD Volume Type AMI
* To start we recommend deploying a 4 node cluster
* Tag each instance with the same name through the AWS EC2 console (REQUIRED!!!)
  * e.g. test-cluster (<cluster-name> in subsequent steps)

Or

Use ec2spinup to deploy a cluster from the command line
```bash
$ ./ec2spinup <instance-template-file>
```

The `instance-template-file` is simply a JSON file that ec2spinup uses. Within this file you will must specify the following as shown:
```python
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

Once the nodes are up and running on AWS, we'll need to grab the DNS and hostname information about the cluster you wish to work with on your local machine.   Make sure your `.pem` key has the proper privelages:
```bash
$ chmod 600 ~/.ssh/<your-aws-pem-key>
```

Always run `ec2fetch` to get the instance DNSs and hostnames before installation. DNSs and hostnames will be saved into the `tmp` folder under the specified cluster name as `public_dns` and `hostnames` respectively
```bash
$ ./ec2fetch <region> <cluster-name>
```
Under the tmp/`<cluster-name>` folder you will find the `public_dns` and `hostnames` files. The first record in each file is considered the Master node for any cluster technology that has a Master-Worker setup.

*tmp/\<cluster-name\>/public_dns*
```bash
ec2-52-32-227-84.us-west-2.compute.amazonaws.com  **MASTER**
ec2-52-10-128-74.us-west-2.compute.amazonaws.com  **WORKER1**
ec2-52-35-15-97.us-west-2.compute.amazonaws.com   **WORKER2**
ec2-52-35-11-46.us-west-2.compute.amazonaws.com   **WORKER3**
```
*tmp/\<cluster-name\>/hostnames*
```bash
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
```bash
$ ./ec2install <cluster-name> environment
$ ./ec2install <cluster-name> ssh
$ ./ec2install <cluster-name> aws
```

Depending on what you decide to install in the environment step, the process could take anywhere from 10-30 minutes. If you wish to speed this up, we recommend that you bake an AMI using [Packer](https://www.packer.io/) and the environment installation script. This will cut down the time to spin up a new cluster significantly. Some examples are shown in the packer folder.

When you use the `ec2spinup` script, you will need to change the instance JSON template to use the new AMI instead of the base Ubuntu 14.04 Trusty AMI

# 5. Start installing!

```bash
$ ./ec2install <cluster-name> <technology>
```
The `technology` tag can be any of the following:
* cassandra (default v2.2.4)
* elasticsearch (default v2.1.0)
  * Must have REGION and EC2_GROUP set as environment variables
  * e.g. REGION=us-west-2
  * e.g. EC2_GROUP=open
* flink (default v0.10.1 with hadoop v2.7 and scala v2.10)
* hadoop (default v2.7.1)
* hbase (default v1.1.2)
* hive (default v1.2.1)
* kafka (default v0.8.2.2 with scala v2.10)
* kibana (default v4.3.0)
* opscenter
* pig (default v0.15.0)
* presto (default v0.86)
* redis (default v3.0.6)
* spark (default v1.5.2 with hadoop v2.4+)
* storm (default v0.10.0)
* tachyon (default v0.8.2)
* zeppelin
* zookeeper (default v3.4.7)

If you wish to install a different version of these technologies, please go into the `install/download_tech` script and update the technology version and technology binary download URL.

Additional technologies can be included into Pegasus by adding the technology version and url to `install/download_tech` and also writing the appropriate configurations in the `config` folder.

# 6. Terminate a cluster

Tears down an on-demand or spot cluster on AWS
```bash
$ ./ec2terminate <region> <cluster-name>
```

# 7. Deployment Pipelines

If you'd like to automate this deployment process completely, you can write your own scripts. An example has been provided in the `templates/pipelines/spark_hadoop.sh` file.

Here it shows how we can spin up a 4 node cluster (ec2spinup) using the `example.json` instance template, grab the cluster information (ec2fetch) and install all the technologies (ec2install) in one script. We can deploy this cluster simply by running the following:
```bash
$ templates/pipelines/spark_hadoop.sh
```
```bash
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
