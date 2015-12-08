## Project pegasus - Flying in the Cloud with Automated AWS Deployment

# 1. Install the boto package for Python on your local machine
This will allow you to programatically interface with your AWS account
```
$ sudo pip install boto
```
Add your AWS credentials to `~/.bash_profile` and source it
```
export AWS_ACCESS_KEY_ID=XXXX
export AWS_SECRET_ACCESS_KEY=XXXX
```
```
$ . ~/.bash_profile
```
# 2. Spin up your cluster on AWS

* Use the Ubuntu Server 14.04 LTS (HVM), SSD Volume Type AMI
* To start we recommend deploying a 4 node cluster

# 3. Fetching AWS cluster DNS and hostname information
Once the nodes are up and running on AWS, we'll need to grab the DNS and hostname information about the cluster you wish to work with on your local machine

Always run `ec2fetch` to get the instance DNSs and hostnames for the next installation. DNSs and hostnames will be saved into the `tmp` folder under the specified cluster name as `public_dns` and `private_dns` respectively
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
$ ./ec2install <pem-key> <cluster-name> environment
$ ./ec2install <pem-key> <cluster-name> ssh
$ ./ec2install <pem-key> <cluster-name> aws
```
# 5. Start installing!
```
$ ./ec2install <pem-key> <cluster-name> <technology>
```
The `technology` tag can be any of the following:
* hadoop
  * hive  (requires hadoop)
  * pig   (requires hadoop)
* spark
* zeppelin
* tachyon
* zookeeper
  *   hbase (requires zookeeper)
  *   kafka (requires zookeeper)
* elasticsearch
  *   kibana (requires elasticsearch)
* cassandra

# 6. Terminate a cluster
Tears down an on-demand or spot cluster on AWS
```
$ ./ec2terminate <pem-key> <cluster-name>
```
