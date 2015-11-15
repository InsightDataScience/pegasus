from boto_util import BotoUtil
import argparse

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('region', help='Region')
    parser.add_argument('instance_name', help='InstanceName')
    args = parser.parse_args()

    BUtil = BotoUtil(args.region)

    dns_tup, cluster_name = BUtil.get_ec2_instances(args.instance_name)
    for dns in dns_tup:
        print dns

    print "Cluster name: {}".format(cluster_name)

    BUtil.write_dns(cluster_name, dns_tup)
