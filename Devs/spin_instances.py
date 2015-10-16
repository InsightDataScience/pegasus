#!/usr/local/bin/python

from boto_util import BotoUtil, InstanceConfig
import argparse

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('region', help='region for instances to spin up')
    parser.add_argument('instance_name', help='instance name to tag each instance')
    parser.add_argument('pem_key', help='region specific pem key to associate instances with')
    parser.add_argument('num_instances', help='number of instances to spin up')
    parser.add_argument('security_groups', help='array of security group names')
    parser.add_argument('instance_type', help='type of instances to spin up')
    parser.add_argument('volume_size', help='size in GB of default EBS volume')

    args = parser.parse_args()

    BUtil = BotoUtil(args.region)
    IConf = InstanceConfig(tag_name=args.instance_name)

    BUtil.create_ec2_spot(IConf)

    dns_tup = BUtil.get_ec2_instances(args.instance_name)
    BUtil.write_dns(args.instance_name, dns_tup)


