## Project Pegasus - Flying in the Cloud with Automated AWS Deployment

This project enables anyone with an Amazon Web Services ([AWS] (http://aws.amazon.com/)) account to quickly deploy a number of distributed technologies all from their laptop or personal computer. The installation is fairly basic and should not be used for production. The purpose of this project is to enable fast protoyping of various distributed data pipelines and also help others explore distributed technologies without the headache of installing them.

We want to continue improving this tool by adding more features and other installations, so send us your pull requests or suggestions!

Supported commands:
* `peg region` - show current region for aws-cli
* `peg up <template-path>` - launch an AWS cluster
* `peg fetch <cluster-name>` - fetch the hostnames and Public DNS of nodes in the AWS cluster
* `peg install <cluster-name> <technology>` - install a technology on the cluster
* `peg service <cluster-name> <technology> <start|stop>` - start and stop a service on the cluster
* `peg uninstall <cluster-name> <technology>` - uninstall a specific technology from the cluster
* `peg ssh <cluster-name> <node-number>` - SSH into a specific node in your AWS cluster
* `peg down <cluster-name>` - terminate a cluster
* `peg retag <cluster-name> <new-cluster-name>` - retag an existing cluster with a different name

# Table of Contents
1. [Install Pegasus on your local machine](README.md#1-install-pegasus-on-your-local-machine)
2. [Spin up your cluster on AWS](README.md#2-spin-up-your-cluster-on-aws)
3. [Fetching AWS cluster DNS and hostname information](README.md#3-fetching-aws-cluster-dns-and-hostname-information)
4. [Setting up a newly provisioned AWS cluster](README.md#4-setting-up-a-newly-provisioned-aws-cluster)
5. [Start installing!](README.md#5-start-installing)
6. [Starting and stopping services](README.md#6-starting-and-stopping-services)
7. [Uninstalling a technology](README.md#6-uninstalling-a-technology)
8. [SSH into a node](README.md#6-ssh-into-a-node)
9. [Terminate a cluster](README.md#7-terminate-a-cluster)
10. [Retag a cluster](README.md#7-retag-a-cluster)
11. [Deployment Pipelines](README.md#8-deployment-pipelines)

# 1. Install Pegasus on your local machine
This will allow you to programatically interface with your AWS account

Clone the Pegasus project to your local computer and install awscli
```bash
$ git clone https://github.com/InsightDataScience/pegasus.git
$ sudo pip install awscli
```

Add your AWS credentials to `~/.bash_profile`, choose a default AWS region and source it
```bash
export AWS_ACCESS_KEY_ID=XXXX
export AWS_SECRET_ACCESS_KEY=XXXX
export AWS_DEFAULT_REGION=us-east-1|us-west-1|us-west-2|eu-central-1|eu-west-1|ap-southeast-1|ap-southeast-2|ap-northeast-1|sa-east-1
export PATH=<path-to-pegasus>:$PATH
```
```bash
$ . ~/.bash_profile
```

You can test your AWS-CLI access by querying for the available regions for your AWS account:
```bash
$ aws ec2 --output json describe-regions --query Regions[].RegionName
[
    "eu-west-1",
    "ap-southeast-1",
    "ap-southeast-2",
    "eu-central-1",
    "ap-northeast-2",
    "ap-northeast-1",
    "us-east-1",
    "sa-east-1",
    "us-west-1",
    "us-west-2"
]
```

# 2. Spin up your cluster on AWS
Currently all installations only work with the Ubuntu Server 14.04 LTS (HVM) AMI.

* Use the Ubuntu Server 14.04 LTS (HVM), SSD Volume Type AMI
* To start we recommend deploying a 4 node cluster
* Tag each instance with the same name through the AWS EC2 console (REQUIRED!!!)
  * e.g. test-cluster (<cluster-name> in subsequent steps)

Or

Use `peg up` to deploy a cluster from the command line (recommended)
```bash
$ peg up <instance-template-file>
```

The `instance-template-file` is simply a yaml file that `peg up` uses. Within this file you will must specify the following as shown:
```bash
purchase_type: spot|on_demand
subnet: string
price: string
num_instances: 4
key_name: string
security_group_ids: string
instance_type: t1.micro|m1.small|m1.medium|m1.large|m1.xlarge|m3.medium|m3.large|m3.xlarge|m3.2xlarge|m4.large|m4.xlarge|m4.2xlarge|m4.4xlarge|m4.10xlarge|t2.micro|t2.small|t2.medium|t2.large|m2.xlarge|m2.2xlarge|m2.4xlarge|cr1.8xlarge|i2.xlarge|i2.2xlarge|i2.4xlarge|i2.8xlarge|hi1.4xlarge|hs1.8xlarge|c1.medium|c1.xlarge|c3.large|c3.xlarge|c3.2xlarge|c3.4xlarge|c3.8xlarge|c4.large|c4.xlarge|c4.2xlarge|c4.4xlarge|c4.8xlarge|cc1.4xlarge|cc2.8xlarge|g2.2xlarge|cg1.4xlarge|r3.large|r3.xlarge|r3.2xlarge|r3.4xlarge|r3.8xlarge|d2.xlarge|d2.2xlarge|d2.4xlarge|d2.8xlarge
tag_name: string
vol_size: 100
```
* **purchase_type** (*string*) - choose between on_demand or spot instances
* **subnet** (*string*) - the VPC subnet id e.g. subnet-61c12804
* **price** (*string*) - spot price you would like to set. Ignored if purchase type is on_demand e.g. 0.25
* **num_instances** (*integer*) - number of instances to deploy
* **key_name** (*string*) - the pem key name to be used for all instances e.g. insight-cluster
* **security_group_ids** (*string*) - security group id e.g. sg-e9f17e8c
* **instance_type** (*string*) - type of instances to deploy
* **tag_name** (*string*) - tag all your instances with this name. This will be known as the `cluster-name` throughout the rest of the README e.g. test-cluster
* **vol_size** (*integer*) - size of the EBS volume in GB. Uses magnetic storage

The AMIs used in the `peg up` script have some basic packages baked in such as Java 7, Python, Maven 3, and many others. You can refer to the [`install/environment/setup_single.sh`](https://github.com/InsightDataScience/pegasus/blob/master/install/environment/install_env.sh) to view all the packages that have been installed. This should save quite a bit of time whenever you provision a new cluster. Reinstalling these packages can take anywhere from 10-30 minutes.

# 3. Fetching AWS cluster DNS and hostname information
Once the nodes are up and running on AWS, we'll need to grab the DNS and hostname information about the cluster you wish to work with on your local machine. Make sure your `.pem` key has the proper privelages:
```bash
$ chmod 600 ~/.ssh/<your-aws-pem-key>
```

Always run `peg fetch` to get the instance DNSs and hostnames before installation. DNSs and hostnames will be saved into the `tmp` folder under the specified cluster name as `public_dns` and `hostnames` respectively
```bash
$ peg fetch <cluster-name>
```
Under the `tmp/<cluster-name>` folder you will find the `public_dns` and `hostnames` files. The first record in each file is considered the Master node for any cluster technology that has a Master-Worker setup.

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
If this is a newly provisioned AWS cluster, always start with at least the following 3 steps in the following order before proceeding with other installations. You can skip the first step if you are using the `peg up` script, since the packages have already been installed.

1. **Environment/Packages** - installs basic packages for Python, Java and many others **(not needed if using peg up)**
1. **Passwordless SSH** - enables passwordless SSH from your computer to the MASTER and the MASTER to all the WORKERS. This is needed for technologies such as Hadoop and Spark.
2. **AWS Credentials** - places AWS keys onto all machines under `~/.profile`
```bash
$ peg install <cluster-name> environment    # not needed if using peg up!!!
$ peg install <cluster-name> ssh
$ peg install <cluster-name> aws
```

# 5. Start installing!
```bash
$ peg install <cluster-name> <technology>
```
The `technology` tag can be any of the following:
* alluxio (default v1.0.0)
* cassandra (default v2.2.5)
* elasticsearch (default v2.1.0)
* flink (default v0.10.1 with hadoop v2.7 and scala v2.10)
* hadoop (default v2.7.1)
* hbase (default v1.1.3)
* hive (default v1.2.1)
* kafka (default v0.8.2.2 with scala v2.10)
* kibana (default v4.3.0)
* opscenter
* pig (default v0.15.0)
* presto (default v0.86)
* redis (default v3.0.6)
* spark (default v1.5.2 with hadoop v2.4+)
* storm (default v0.10.0)
* zeppelin
* zookeeper (default v3.4.6)

All environment variables are stored in `~/.profile` such as `HADOOP_HOME`, `SPARK_HOME` and so on.

If you wish to install a different version of these technologies, please go into the [`install/download_tech`](https://github.com/InsightDataScience/pegasus/blob/master/install/download_tech) script and update the technology version and technology binary download URL.

Additional technologies can be included into Pegasus by adding the technology version and url to [`install/download_tech`](https://github.com/InsightDataScience/pegasus/blob/master/install/download_tech) and also writing the appropriate configurations in the `config` folder.

# 6. Starting and stopping services
A script have been provided to start and stop distributed services easily without having to manually SSH into each node
```bash
$ peg service <cluster-name> <technology> <start|stop>
```

# 7. Uninstalling a technology
A script have been provided to uninstall a specific technology from all nodes in the declared cluster
```bash
$ peg uninstall <cluster-name> <technology>
```

# 8. SSH into a node
If you need to SSH into a specific node in a cluster, you can use the `ec2ssh` script to easily reference nodes
```bash
$ peg ssh <cluster-name> <node-number>
```
where `node-number` is the order in which the nodes appear in the `hostnames` and `public_dns` files starting with 1

# 9. Terminate a cluster
Tears down an on-demand or spot cluster on AWS
```bash
$ peg down <cluster-name>
```

# 10. Retag a cluster
Retag an existing cluster on AWS
```bash
$ peg retag <cluster-name> <new-cluster-name>
```

# 11. Deployment Pipelines
If you'd like to automate this deployment process completely, you can write your own scripts. An example has been provided in the [`templates/pipelines/spark_hadoop.sh`](https://github.com/InsightDataScience/pegasus/blob/master/templates/pipelines/spark_hadoop.sh) file.

Here it shows how we can spin up a 4 node cluster (peg up) using the [`example.yml`](https://github.com/InsightDataScience/pegasus/blob/master/templates/instances/example.yml) instance template, grab the cluster information using `peg fetch` and install all the technologies with `peg install` in one script. We can deploy this cluster simply by running the following:
```bash
$ templates/pipelines/spark_hadoop.sh
```
```bash
#!/bin/bash

CLUSTER_NAME=test-cluster

peg up templates/instances/example.yml

peg fetch $CLUSTER_NAME

peg install $CLUSTER_NAME ssh
peg install $CLUSTER_NAME aws
peg install $CLUSTER_NAME hadoop
peg install $CLUSTER_NAME hive
peg install $CLUSTER_NAME pig
peg install $CLUSTER_NAME spark
```
