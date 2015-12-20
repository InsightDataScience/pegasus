from util.boto_util import InstanceConfig, BotoUtil

class TestBotoUtil:

    def test_boto_util_region_default(self):
        butil = BotoUtil()

        assert butil.client.meta.region_name == 'us-west-2'

    def test_boto_util_region_set(self):
        butil = BotoUtil('us-east-1')

        assert butil.client.meta.region_name == 'us-east-1'

