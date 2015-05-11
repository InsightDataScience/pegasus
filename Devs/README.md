##### 1. Spin up AWS Instances
![AWSConsole] (/images/AWSConsole.png)
![EC2Dashboard] (/images/EC2Dashboard.png)
![ChooseAMI] (/images/ChooseAMI.png)
![ChooseInstance] (/images/ChooseInstance.png)
![InstanceDetails] (/images/InstanceDetails.png)
![AddStorage] (/images/AddStorage.png)
![TagInstance] (/images/TagInstance.png)
![SecurityGroup] (/images/SecurityGroup.png)

Save your AWS .pem key to ~/.ssh
* Create one if you don't have one associated with your AWS account
* Change permissions for the pem-key
```
localuser@LOCAL_NAME:~$ chmod 600 ~/.ssh/<personal.pem>
```
##### 2. Install the boto package for python
This will allow you to programatically interface with your AWS account
```
localuser@LOCAL_NAME:~$ sudo pip install boto
```
Create a .boto file in your home directory
```
localuser@LOCAL_NAME:~$ touch ~/.boto
```
Insert the following into .boto with your AWS credentials
```
[Credentials]
aws_access_key_id = XXXXXX
aws_secret_access_key = XXXXX+XXXX
```
##### 3. Clone repository
* Place in home folder
* Move into the ClusterUtilities folder
```
localuser@LOCAL_NAME:~$ git clone https://github.com/InsightDataScience/ClusterUtilities.git
localuser@LOCAL_NAME:~$ cd ClusterUtilities
```
