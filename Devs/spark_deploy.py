from boto_util import BotoUtil 
import argparse
import os
import time

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('region', help='Region')
    parser.add_argument('instance_name', help='InstanceName')
    args = parser.parse_args()

    BUtil = BotoUtil("us-west-2")

    BUtil.create_ec2_instance(4, "insight-cluster", ["open"], "t2.medium", args.instance_name)

    time.sleep(10)

    dns_tup = BUtil.get_ec2_instances(args.instance_name)
    BUtil.write_dns(args.instance_name, dns_tup)

    os.system("./install_hadoop.sh %s %s" % ("~/.ssh/insight-cluster.pem", args.instance_name))

    os.system("./install_spark.sh %s %s" % ("~/.ssh/insight-cluster.pem", args.instance_name))

