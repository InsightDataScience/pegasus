from moto import mock_ec2
import boto3
from util.boto_util import InstanceConfig, BotoUtil

class TestBotoUtil(object):

    @mock_ec2
    def test_boto_util_region_default(self):
        butil = BotoUtil()

        assert butil.client.meta.region_name == 'us-west-2'

    @mock_ec2
    def test_boto_util_region_set(self):
        butil = BotoUtil('us-east-1')

        assert butil.client.meta.region_name == 'us-east-1'

    @mock_ec2
    def test_request_on_demand(self):
        region = 'us-west-2'
        ami_dummy = 'ami-1234abcd' # default mock ami

        client = boto3.client('ec2', region)

        # setup mock vpc
        vpc = client.create_vpc(CidrBlock="10.0.0.0/16")
        vpc_id = vpc['Vpc']['VpcId']

        # setup mock subnet
        subnet = client.create_subnet(VpcId=vpc_id, CidrBlock="10.0.0.0/20")
        subnet_id = subnet['Subnet']['SubnetId']

        # setup mock key pair
        kp = client.create_key_pair(KeyName="instance-cluster")
        kp_name = kp['KeyName']

        # setup mock security group
        security_group = client.create_security_group(
            GroupName="sg-test",
            Description="test security group",
            VpcId=vpc_id)
        security_group_id = security_group['GroupId']

        # create InstanceConfig class with mocked parameters
        params = {'region': unicode(region),
                  'subnet': unicode(subnet_id),
                  'purchase_type': u'on_demand',
                  'image': unicode(ami_dummy),
                  'price': u'0.25',
                  'num_instances': 4,
                  'key_name': unicode(kp_name),
                  'security_group_ids': [unicode(security_group_id)],
                  'instance_type': u'm4x.large',
                  'tag_name': u'test-cluster',
                  'vol_size': 100
                 }

        inst_conf = InstanceConfig(params)

        # run on demand instance
        if inst_conf.is_valid():
            butil = BotoUtil(region)
            butil.request_ondemand(inst_conf)

        # fetch all on demand instances
        response = client.describe_instances()

        num_instances = 0
        ami_ids = []
        key_names = []
        security_group_ids = []
        instance_types = []

        for reservation in response['Reservations']:
            num_instances += len(reservation['Instances'])
            for instance in reservation['Instances']:
                ami_ids.append(instance['ImageId'])
                key_names.append(instance['KeyName'])
                security_group_ids.append(instance['SecurityGroups'][0]['GroupId'])
                instance_types.append(instance['InstanceType'])

        assert num_instances == 4
        assert len(set(ami_ids)) == 1
        assert ami_ids[0] == ami_dummy
        assert len(set(key_names)) == 1
        assert key_names[0] == kp_name
        assert len(set(security_group_ids)) == 1
        assert security_group_ids[0] == security_group_id
        assert len(set(instance_types)) == 1
        assert instance_types[0] == 'm4x.large'

    @mock_ec2
    def test_request_spot(self):
        region = 'us-west-2'
        ami_dummy = 'ami-1234abcd' # default mock ami

        client = boto3.client('ec2', region)

        # setup mock vpc
        vpc = client.create_vpc(CidrBlock="10.0.0.0/16")
        vpc_id = vpc['Vpc']['VpcId']

        # setup mock subnet
        subnet = client.create_subnet(VpcId=vpc_id, CidrBlock="10.0.0.0/20")
        subnet_id = subnet['Subnet']['SubnetId']

        # setup mock key pair
        kp = client.create_key_pair(KeyName="instance-cluster")
        kp_name = kp['KeyName']

        # setup mock security group
        security_group = client.create_security_group(
            GroupName="sg-test",
            Description="test security group",
            VpcId=vpc_id)
        security_group_id = security_group['GroupId']

        # create InstanceConfig class with mocked parameters
        params = {'region': unicode(region),
                  'subnet': unicode(subnet_id),
                  'purchase_type': u'spot',
                  'image': unicode(ami_dummy),
                  'price': u'0.25',
                  'num_instances': 4,
                  'key_name': unicode(kp_name),
                  'security_group_ids': [unicode(security_group_id)],
                  'instance_type': u'm4x.large',
                  'tag_name': u'test-cluster',
                  'vol_size': 100
                 }

        inst_conf = InstanceConfig(params)

        # request spot instance
        if inst_conf.is_valid():
            butil = BotoUtil(region)
            spot_req_ids = butil.request_spot(inst_conf)

        # fetch all on demand instances
        response = client.describe_spot_instance_requests(SpotInstanceRequestIds=spot_req_ids)

        num_requests = len(response['SpotInstanceRequests'])
        ami_ids = []
        key_names = []
        security_group_ids = []
        instance_types = []
        spot_request_ids = []
        spot_prices = []
        spot_names = []

        for spot_requests in response['SpotInstanceRequests']:
            spot_request_ids.append(spot_requests['SpotInstanceRequestId'])
            spot_prices.append(spot_requests['SpotPrice'])
            spot_names.append(spot_requests['Tags'][0]['Value'])

            launch_spec = spot_requests['LaunchSpecification']
            ami_ids.append(launch_spec['ImageId'])
            key_names.append(launch_spec['KeyName'])
            security_group_ids.append(launch_spec['SecurityGroups'][0]['GroupId'])
            instance_types.append(launch_spec['InstanceType'])

        assert num_requests == 4
        assert len(set(ami_ids)) == 1
        assert ami_ids[0] == ami_dummy
        assert len(set(key_names)) == 1
        assert key_names[0] == kp_name
        assert len(set(security_group_ids)) == 1
        #assert security_group_ids[0] == security_group_id
        assert len(set(instance_types)) == 1
        assert instance_types[0] == 'm4x.large'
        assert len(set(spot_prices)) == 1
        assert spot_prices[0] == '0.25'
        assert len(set(spot_names)) == 1
        assert spot_names[0] == 'test-cluster'


