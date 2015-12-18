from util.boto_util import InstanceConfig

class TestInstanceConfig:

    def test_bdm_vol_size_int(self):
        params = {"vol_size": 100}

        inst_conf = InstanceConfig(params)
        bdm = inst_conf.create_block_device_map()

        assert bdm['Ebs']['VolumeSize'] == 100


