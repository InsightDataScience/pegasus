## Project Pegasus - Flying in the Cloud with Automated AWS Deployment

This project enables anyone with an Amazon Web Services ([AWS] (http://aws.amazon.com/)) account to quickly deploy a number of distributed technologies all from their laptop or personal computer. The installation is fairly basic and should not be used for production. The purpose of this project is to enable fast protoyping of various distributed data pipelines and also help others explore distributed technologies without the headache of installing them.

We want to continue improving this tool by adding more features and other installations, so send us your pull requests or suggestions!

Supported commands:
* `peg aws <options>` - query AWS for information about vpcs, subnets, and security groups.
* `peg validate <template-path>` - check if proper fields are set in the instance template yaml file
* `peg up <template-path>` - launch an AWS cluster using the instance template yaml file
* `peg fetch <cluster-name>` - fetch the hostnames and Public DNS of nodes in the AWS cluster and store locally
* `peg describe <cluster-name>` - show the type of instances, hostnames, and Public DNS of nodes in the AWS cluster
* `peg install <cluster-name> <technology>` - install a technology on the cluster
* `peg service <cluster-name> <technology> <start|stop>` - start and stop a service on the cluster
* `peg uninstall <cluster-name> <technology>` - uninstall a specific technology from the cluster
* `peg ssh <cluster-name> <node-number>` - SSH into a specific node in your AWS cluster
* `peg down <cluster-name>` - terminate a cluster
* `peg retag <cluster-name> <new-cluster-name>` - retag an existing cluster with a different name
* `peg start <cluster-name>` - start an existing cluster with on demand instances and put into running mode
* `peg stop <cluster-name>` - stop and existing cluster with on demand instances and put into stop mode
* `peg port-forward <cluster-name> <node-number> <local-port>:<remote-port>` - port forward your local port to the remote cluster node's port

# Table of Contents
1. [Install Pegasus on your local machine](README.md#install-pegasus-on-your-local-machine)
2. [Query for AWS VPC information](README.md#query-for-aws-vpc-information)
3. [Spin up your cluster on AWS](README.md#spin-up-your-cluster-on-aws)
4. [Fetching AWS cluster DNS and hostname information](README.md#fetching-aws-cluster-dns-and-hostname-information)
5. [Describe cluster information](README.md#describe-a-cluster)
6. [Setting up a newly provisioned AWS cluster](README.md#setting-up-a-newly-provisioned-aws-cluster)
7. [Start installing!](README.md#start-installing)
8. [Starting and stopping services](README.md#starting-and-stopping-services)
9. [Uninstalling a technology](README.md#uninstalling-a-technology)
10. [SSH into a node](README.md#ssh-into-a-node)
11. [Terminate a cluster](README.md#terminate-a-cluster)
12. [Retag a cluster](README.md#retag-a-cluster)
13. [Starting and stopping on demand clusters](README.md#starting-stopping-on-demand-clusters)
14. [Port forwarding to a node](README.md#port-forwarding-to-a-node)
15. [Deployment Pipelines](README.md#deployment-pipelines)

# Install Pegasus on your local machine
This will allow you to programatically interface with your AWS account

Clone the Pegasus project to your local computer and install awscli
```bash
$ git clone https://github.com/InsightDataScience/pegasus.git
$ sudo pip install awscli
```

Next we need to add the following to your `~/.bash_profile`.
```bash
export AWS_ACCESS_KEY_ID=XXXX
export AWS_SECRET_ACCESS_KEY=XXXX
export AWS_DEFAULT_REGION=us-east-1|us-west-1|us-west-2|eu-central-1|eu-west-1|ap-southeast-1|ap-southeast-2|ap-northeast-1|sa-east-1
export REM_USER=ubuntu
export PATH=<path-to-pegasus>:$PATH
```
Source the `.bash_profile` when finished.
```bash
$ source ~/.bash_profile
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

# Query for AWS VPC information
## VPCs
View all VPCs in your region with `peg aws vpcs`
```bash
$ peg aws vpcs
VPCID		    NAME
vpc-add2e6c3	default
vpc-c2a496a1	my-vpc
```
## Subnets
View all Subnets in your region with `peg aws subnets`
```bash
$ peg aws subnets
VPCID		    AZ		    IPS	    SUBNETID	    NAME
vpc-c2a496a1	us-west-2c	251	    subnet-6ac0bd26	private-subnet-west-2c
vpc-add2e6c3	us-west-2b	4089	subnet-9fe6e3df	aws-us-west-2b
```

You can filter Subnets down to a specific VPC name with `peg aws subnets <vpc-name>`
```bash
$ peg aws subnets my-vpc
VPCID		    AZ		    IPS	    SUBNETID	    NAME
vpc-c2a496a1	us-west-2c	251	    subnet-6ac0bd26	private-subnet-west-2c
```

## Security groups
View all Security Groups in your region with `peg aws security-groups`
```bash
$ peg aws security-groups
VPCID		    SGID		GROUP NAME
vpc-add2e6c3	sg-7cb78418	default
vpc-c2a496a1	sg-5deed039	default
```

You can filter Security Groups down to a specific VPC name `peg aws security-groups <vpc-name>`
```bash
$ peg aws security-groups my-vpc
VPCID		    SGID		GROUP NAME
vpc-c2a496a1	sg-5deed039	default
```

## Region
Lastly you can double check which AWS region Pegasus is using with `peg aws region`. If the value is not what you expect, update your `AWS_DEFAULT_REGION` in your `.bash_profile` and source it before proceeding.
```bash
$ peg aws region
Pegasus is using AWS region us-west-2
```

# Spin up your cluster on AWS
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

The `instance-template-file` is a yaml file that `peg up` uses. Within this file you should specify the following as shown:
```bash
purchase_type: spot|on_demand
subnet: string
price: string
num_instances: integer
key_name: string
security_group_ids: string
instance_type: t1.micro|m1.small|m1.medium|m1.large|m1.xlarge|m3.medium|m3.large|m3.xlarge|m3.2xlarge|m4.large|m4.xlarge|m4.2xlarge|m4.4xlarge|m4.10xlarge|t2.micro|t2.small|t2.medium|t2.large|m2.xlarge|m2.2xlarge|m2.4xlarge|cr1.8xlarge|i2.xlarge|i2.2xlarge|i2.4xlarge|i2.8xlarge|hi1.4xlarge|hs1.8xlarge|c1.medium|c1.xlarge|c3.large|c3.xlarge|c3.2xlarge|c3.4xlarge|c3.8xlarge|c4.large|c4.xlarge|c4.2xlarge|c4.4xlarge|c4.8xlarge|cc1.4xlarge|cc2.8xlarge|g2.2xlarge|cg1.4xlarge|r3.large|r3.xlarge|r3.2xlarge|r3.4xlarge|r3.8xlarge|d2.xlarge|d2.2xlarge|d2.4xlarge|d2.8xlarge
tag_name: string
vol_size: integer
```
* **purchase_type** (*string*) - choose between on_demand or spot instances
* **subnet** (*string*) - the VPC subnet id e.g. subnet-61c12804
* **price** (*string*) - spot price you would like to set. Ignored if `purchase_type`=`on_demand` e.g. 0.25
* **num_instances** (*integer*) - number of instances to deploy
* **key_name** (*string*) - the pem key name to be used for all instances e.g. insight-cluster
* **security_group_ids** (*string*) - security group id e.g. sg-e9f17e8c (does not support multiple security group ids yet)
* **instance_type** (*string*) - type of instances to deploy
* **tag_name** (*string*) - tag all your instances with this name. This will be known as the `cluster-name` throughout the rest of the README e.g. test-cluster
* **vol_size** (*integer*) - size of the EBS volume in GB. Uses magnetic storage

You can check if the template file is valid with `peg validate <template-file`. If nothing is shown, then the file should work with `peg up`.

The AMIs used in the `peg up` script have some basic packages baked in such as Java 7, Python, Maven 3, and many others. You can refer to the [`install/environment/setup_single.sh`](https://github.com/InsightDataScience/pegasus/blob/master/install/environment/install_env.sh) to view all the packages that have been installed. This should save quite a bit of time whenever you provision a new cluster. Reinstalling these packages can take anywhere from 10-30 minutes.

# Fetching AWS cluster DNS and hostname information
Once the nodes are up and running on AWS, we'll need to grab the DNS and hostname information about the cluster you wish to work with on your local machine. Make sure your `.pem` key has the proper privileges:
```bash
$ chmod 600 ~/.ssh/<your-aws-pem-key>
```

Always run `peg fetch` to store the instance DNSs and hostnames onto your local machine before installation. DNSs and hostnames will be saved into the `tmp` folder under the specified cluster name as `public_dns` and `hostnames` respectively
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

# Describe a cluster
Shows the hostname and Public DNS for a specified cluster and also show which nodes are the Master vs Workers.
```bash
$ peg describe <cluster-name>
```

# Setting up a newly provisioned AWS cluster
If this is a newly provisioned AWS cluster, always start with at least the following 3 steps in the following order before proceeding with other installations. You can skip the first step if you are using the `peg up` script, since the packages have already been installed.

1. **Environment/Packages** - installs basic packages for Python, Java and many others **(not needed if using peg up)**
1. **Passwordless SSH** - enables passwordless SSH from your computer to the MASTER and the MASTER to all the WORKERS. This is needed for some of the technologies.
2. **AWS Credentials** - places AWS keys onto all machines under `~/.profile`
```bash
$ peg install <cluster-name> environment    # not needed if using peg up!!!
$ peg install <cluster-name> ssh
$ peg install <cluster-name> aws
```

# Start installing!
```bash
$ peg install <cluster-name> <technology>
```
The `technology` tag can be any of the following:
* alluxio (default v1.0.0)
* cassandra (default v2.2.5)
* elasticsearch (default v2.1.0)
* flink (default v1.0.0 with hadoop v2.7 and scala v2.10)
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

All environment variables relating to technology folder paths are stored in `~/.profile` such as `HADOOP_HOME`, `SPARK_HOME` and so on.

If you wish to install a different version of these technologies, please go into the [`install/download_tech`](https://github.com/InsightDataScience/pegasus/blob/master/install/download_tech) script and update the technology version and technology binary download URL.

Additional technologies can be included into Pegasus by adding the technology version and url to [`install/download_tech`](https://github.com/InsightDataScience/pegasus/blob/master/install/download_tech) and also writing the appropriate configurations in the `config` folder.

# Starting and stopping services
A script has been provided to start and stop distributed services easily without having to manually SSH into each node
```bash
$ peg service <cluster-name> <technology> <start|stop>
```

# Uninstalling a technology
A script has been provided to uninstall a specific technology from all nodes in the declared cluster
```bash
$ peg uninstall <cluster-name> <technology>
```

# SSH into a node
If you need to SSH into a specific node in a cluster, you can use `peg ssh` to easily reference nodes
```bash
$ peg ssh <cluster-name> <node-number>
```
where `node-number` is the order in which the nodes appear in the `hostnames` and `public_dns` files starting with 1 (master node)

# Terminate a cluster
Tears down an on-demand or spot cluster on AWS
```bash
$ peg down <cluster-name>
```

# Retag a cluster
Retag an existing cluster on AWS
```bash
$ peg retag <cluster-name> <new-cluster-name>
```

# Starting and stopping on demand clusters
Place a cluster into running and stop modes on AWS.
```bash
$ peg start <cluster-name>
```
```bash
$ peg stop <cluster-name>
```

# Port forwarding to a node
Forward your local port to a remote node's port
```bash
$ peg port-forward <cluster-name> <node-number> <local-port>:<remote-port>
```

# Deployment Pipelines
If you'd like to automate this deployment process completely, you can write your own scripts. An example has been provided in the [`examples/spark_hadoop.sh`](https://github.com/InsightDataScience/pegasus/blob/master/examples/spark_hadoop.sh) file.

Here it shows how we can spin up a 4 node cluster (peg up) using the [`spark_master.yml`](https://github.com/InsightDataScience/pegasus/blob/master/examples/spark_master.yml) and [`spark_workers.yml`](https://github.com/InsightDataScience/pegasus/blob/master/examples/spark_workers.yml) instance templates, grab the cluster information using `peg fetch` and install all the technologies with `peg install` in one script. We can deploy this cluster simply by running the following:
```bash
$ examples/spark_hadoop.sh
```
```bash
#!/bin/bash

PEG_ROOT=$(dirname ${BASH_SOURCE})/..

CLUSTER_NAME=test-cluster

peg up ${PEG_ROOT}/example/spark_master.yml &
peg up ${PEG_ROOT}/example/spark_workers.yml &

wait

peg fetch $CLUSTER_NAME

peg install ${CLUSTER_NAME} ssh
peg install ${CLUSTER_NAME} aws
peg install ${CLUSTER_NAME} hadoop
peg install ${CLUSTER_NAME} spark

peg port-forward ${CLUSTER_NAME} 1 8888:8888
```
