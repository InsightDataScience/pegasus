from util.boto_util import InstanceConfig

class TestInstanceConfig(object):

    def test_is_valid_one_correct_key(self):
        params = {"vol_size": 100}

        inst_conf = InstanceConfig(params)

        assert inst_conf.is_valid() is False

    def test_is_valid_correct_keys_str(self):
        params = {'region': 'us-west-2',
                  'subnet': 'subnet-3a78835f',
                  'purchase_type': 'on_demand',
                  'image': 'ami-5189a661',
                  'price': '0.25',
                  'num_instance': 4,
                  'key_name': 'instance-cluster',
                  'security_group_ids': ['sg-9206aaf7'],
                  'instance_type': 'm4x.large',
                  'tag_name': 'test-cluster',
                  'vol_size': 100,
                  'bdm': {}
                 }

        inst_conf = InstanceConfig(params)

        assert inst_conf.is_valid() is False

    def test_is_valid_correct_keys_uni(self):
        params = {'region': u'us-west-2',
                  'subnet': u'subnet-3a78835f',
                  'purchase_type': u'on_demand',
                  'image': u'ami-5189a661',
                  'price': u'0.25',
                  'num_instances': 4,
                  'key_name': u'instance-cluster',
                  'security_group_ids': [u'sg-9206aaf7'],
                  'instance_type': u'm4x.large',
                  'tag_name': u'test-cluster',
                  'vol_size': 100
                 }

        inst_conf = InstanceConfig(params)

        assert inst_conf.is_valid() is True

    def test_is_valid_missing_a_key(self):
        params = {'region': u'us-west-2',
                  'subnet': u'subnet-3a78835f',
                  'purchase_type': u'on_demand',
                  'image': u'ami-5189a661',
                  'price': u'0.25',
                  'key_name': u'instance-cluster',
                  'security_group_ids': [u'sg-9206aaf7'],
                  'instance_type': u'm4x.large',
                  'tag_name': u'test-cluster',
                  'vol_size':100
                 }

        inst_conf = InstanceConfig(params)

        assert inst_conf.is_valid() is False

    def test_is_valid_spot_instance(self):
        params = {'region': u'us-west-2',
                  'subnet': u'subnet-3a78835f',
                  'purchase_type': u'spot',
                  'image': u'ami-5189a661',
                  'price': u'0.25',
                  'num_instances': 4,
                  'key_name': u'instance-cluster',
                  'security_group_ids': [u'sg-9206aaf7'],
                  'instance_type': u'm4x.large',
                  'tag_name': u'test-cluster',
                  'vol_size':100
                 }

        inst_conf = InstanceConfig(params)

        assert inst_conf.is_valid() is True

    def test_is_valid_num_instances_str(self):
        params = {'region': u'us-west-2',
                  'subnet': u'subnet-3a78835f',
                  'purchase_type': u'spot',
                  'image': u'ami-5189a661',
                  'price': u'0.25',
                  'num_instances': "4",
                  'key_name': u'instance-cluster',
                  'security_group_ids': [u'sg-9206aaf7'],
                  'instance_type': u'm4x.large',
                  'tag_name': u'test-cluster',
                  'vol_size':100
                 }

        inst_conf = InstanceConfig(params)

        assert inst_conf.is_valid() is False


