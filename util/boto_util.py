"""Example style docstrings
"""
import json
import os
import shutil
from time import sleep
import boto3
from schema import Schema, And

class BotoUtil(object):
    """All boto related functions to be used in Pegasus
    """
    def __init__(self, region='us-west-2'):
        self.client = boto3.client('ec2', region)

    def launch_instances(self, inst_conf):
        """Launch spot or on demand instances

        Args:
            inst_conf: InstanceConfig class type

        Returns:
            None

        """

        if inst_conf.purchase_type == "on_demand":
            inst_ids = self.request_ondemand(inst_conf)
        elif inst_conf.purchase_type == "spot":
            spot_req_ids = self.request_spot(inst_conf)
            inst_ids = self.wait_for_instance_ids_from_spot(spot_req_ids)
        else:
            return

        sleep(1)

        self.client.create_tags(
            Resources=inst_ids,
            Tags=[{'Key': 'Name', 'Value': inst_conf.tag_name}]
        )

        print "Waiting for running instances: {}".format(inst_ids)
        waiter = self.client.get_waiter('instance_running')
        waiter.wait(InstanceIds=inst_ids)
        print "Instances running"

        print "Waiting for instance status ok: {}".format(inst_ids)
        waiter = self.client.get_waiter('instance_status_ok')
        waiter.wait(InstanceIds=inst_ids)
        print "Instances with status ok"


    def request_spot(self, inst_conf):
        """Create spot requests based on the InstanceConfig class

        Does a linking of the InstanceConfig class variables to the boto3 API

        Args:
            inst_conf: InstanceConfig class type

        Returns:
            list of instance IDs
        """

        spot_req = self.client.request_spot_instances(
            SpotPrice=inst_conf.price,
            InstanceCount=inst_conf.num_instances,
            Type='one-time',
            LaunchSpecification={
                'ImageId': inst_conf.image,
                'KeyName': inst_conf.key_name,
                'InstanceType': inst_conf.instance_type,
                'BlockDeviceMappings': [inst_conf.bdm],
                'SubnetId': inst_conf.subnet,
                'Monitoring': {
                    'Enabled': False
                },
                'SecurityGroupIds': inst_conf.security_group_ids
            }
        )

        spot_req_ids = [sr['SpotInstanceRequestId'] for sr in spot_req['SpotInstanceRequests']]

        sleep(1)

        self.client.create_tags(
            Resources=spot_req_ids,
            Tags=[{'Key': 'Name', 'Value': inst_conf.tag_name}]
        )

        return spot_req_ids

    def wait_for_instance_ids_from_spot(self, spot_req_ids):
        """Wait for spot requests to be fulfilled and grab the instance ids

        Args:
            spot_req_ids: a list of spot request ids in string format

        Returns:
            a list of instance ids in string format
        """

        print "Waiting on spot requests: {}".format(spot_req_ids)
        waiter = self.client.get_waiter('spot_instance_request_fulfilled')
        waiter.wait(SpotInstanceRequestIds=spot_req_ids)
        print "Spot instances fullfilled"

        spot_req = self.client.describe_spot_instance_requests(SpotInstanceRequestIds=spot_req_ids)

        inst_ids = [sr['InstanceId'] for sr in spot_req['SpotInstanceRequests']]

        return inst_ids

    def request_ondemand(self, inst_conf):
        """Create on demand reservations based on the InstanceConfig class

        Does a linking of the InstanceConfig class variables to the boto3 API

        Args:
            inst_conf: InstanceConfig class type

        Returns:
            dictionary of Reservations
        """

        reservations = self.client.run_instances(
            MinCount=inst_conf.num_instances,
            MaxCount=inst_conf.num_instances,
            ImageId=inst_conf.image,
            KeyName=inst_conf.key_name,
            InstanceType=inst_conf.instance_type,
            BlockDeviceMappings=[inst_conf.bdm],
            SubnetId=inst_conf.subnet,
            Monitoring={
                'Enabled': False
            },
            SecurityGroupIds=inst_conf.security_group_ids
        )

        inst_ids = [r['InstanceId'] for r in reservations['Instances']]

        return inst_ids

    def fetch_instances(self, cluster_name):
        """Grab the public dns and hostname of all instances with matching cluster names

        Args:
            cluster_name: A string that represents the cluster tag name in AWS.
              This does not have to be exact, since wildcards are used in the
              filtering

        Returns:
            a tuple with the DNS, cluster name, and pem key name

        """

        reservations = self.client.describe_instances(
            Filters=[{'Name': 'instance-state-name', 'Values': ['running']},
                     {'Name': 'tag:Name', 'Values': ['*{}*'.format(cluster_name)]}]
        )

        dns = []
        instance_type = {}
        pem_keys = []

        for reservation in reservations['Reservations']:
            for instance in reservation['Instances']:
                priv_name = "ip-" + str(instance['PrivateIpAddress']).replace('.', '-')
                pub_name = instance['PublicDnsName']
                dns.append((priv_name, pub_name))
                pem_keys.append(instance['KeyName'])

                if instance['InstanceType'] in instance_type:
                    instance_type[instance['InstanceType']] += 1
                else:
                    instance_type[instance['InstanceType']] = 1

                tags = instance['Tags']
                for tag in tags:
                    if tag['Key'] == 'Name':
                        print "Instance name {} using {} key".format(tag['Value'],\
                            instance['KeyName'])

        dns.sort()

        print json.dumps(instance_type, indent=2, sort_keys=True)

        if len(set(pem_keys)) == 1:
            msg = "{} instances found in {} with the name {}"
            print msg.format(len(pem_keys), self.client.meta.region_name, cluster_name)
            return dns, cluster_name, pem_keys[0]
        elif len(set(pem_keys)) > 1:
            msg = "Instances with the name {} do not have the same pem keys!"
            print msg.format(cluster_name)
            return
        else:
            msg = "No instances found in {} with the name {}"
            print msg.format(self.client.meta.region_name, cluster_name)
            return

    def terminate_cluster(self, ips):
        """Searches for instances with the ips terminates them on AWS

        Args:
            ips: a list of public IPs for the instances to be terminated

        Returns:
            None

        """

        instance_ids = []
        request_ids = []

        reservations = self.client.describe_instances(
            Filters=[{'Name': 'ip-address', 'Values': ips}]
        )

        for reservation in reservations['Reservations']:
            for instance in reservation['Instances']:
                instance_ids.append(instance['InstanceId'])
                if 'SpotInstanceRequestId' in instance:
                    request_ids.append(instance['SpotInstanceRequestId'])

        if len(instance_ids) > 0:
            print "{} terminating ...".format(instance_ids)
            self.client.terminate_instances(InstanceIds=instance_ids)
        else:
            print "No instances with IPs: {}".format(ips)

        if len(request_ids) > 0:
            print "{} spot requests cancelling ...".format(request_ids)
            self.client.cancel_spot_instance_requests(SpotInstanceRequestIds=request_ids)

class InstanceConfig(object):
    """Class defining ec2 instance configurations
    """
    def __init__(self, params):
        self.__dict__.update(params)
        self.bdm = self.create_block_device_map()

    def create_block_device_map(self):
        """Create a block device map for an ec2 instance

        Uses the InstanceConfig class to create a block device map

        Args:
            None

        Returns:
            A block device map to be used by an instance

        Example:
            bdm = IC.create_block_device_map()
        """

        bdm = {}

        bdm['DeviceName'] = '/dev/sda1'

        bdm['Ebs'] = {}
        bdm['Ebs']['VolumeSize'] = self.__dict__['vol_size']
        bdm['Ebs']['DeleteOnTermination'] = True
        bdm['Ebs']['VolumeType'] = "standard"

        return bdm

    def is_valid(self):
        """Checks if the input dictionary contains all valid types

        Checks the __dict__ attribute and ensure it follows the correct
        schema

        Args:
            None

        Returns:
            A Boolean if dictionary follows schema
        """

        schema = Schema({
            'region': unicode,
            'subnet': unicode,
            'purchase_type': And(unicode, lambda x: x in ["on_demand", "spot"]),
            'image': unicode,
            'price': unicode,
            'num_instances': int,
            'key_name': unicode,
            'security_group_ids': list,
            'instance_type': unicode,
            'tag_name': unicode,
            'vol_size': int,
            'bdm': dict})

        try:
            schema.validate(self.__dict__)
            return True
        except Exception as exc:
            print exc
            print "Invalid instance template"
            return False


def remove_cluster_info(cluster_name):
    """Removes the directory path for specified cluster

    Args:
        cluster_name: string representing the cluster name stored locally

    Returns:
        None

    """

    cluster_info_path = "tmp/{}".format(cluster_name)
    if os.path.exists(cluster_info_path):
        shutil.rmtree(cluster_info_path)

def write_dns(cluster_name, dns_tup):
    """Writes the public dns and hostname to the cluster folder

    Args:
        cluster_name: string representing the cluster name
        dns_tup: array of paired tuples where the first element is the
          hostname and the second is the public DNS

    Returns:
        None

    """

    cluster_info_path = "tmp/{}".format(cluster_name)
    os.makedirs(cluster_info_path)

    f_priv = open('{}/private_dns'.format(cluster_info_path), 'w')
    f_pub = open('{}/public_dns'.format(cluster_info_path), 'w')

    for pair in dns_tup:
        f_priv.write(pair[0] + "\n")
        f_pub.write(pair[1] + "\n")

    f_priv.close()
    f_pub.close()

def copy_pem(cluster_name, pem_name):
    """Copies the pem key found locally to the cluster folder

    Args:
        cluster_name: string representing the cluster
        pem_name: string representing the pem key to be copied over

    Returns:
        None

    """

    cluster_info_path = "tmp/{}".format(cluster_name)
    pem_key_loc = "{}/.ssh/{}.pem".format(os.path.expanduser("~"), pem_name)
    shutil.copy(pem_key_loc, cluster_info_path)

