import argparse
from util.boto_util import BotoUtil, remove_cluster_info, write_dns, copy_pem

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('region', help='Region')
    parser.add_argument('cluster_name', help='Cluster Name')
    args = parser.parse_args()

    BUtil = BotoUtil(args.region)

    remove_cluster_info(args.cluster_name)

    cluster_info = BUtil.fetch_instances(args.cluster_name)

    if cluster_info is not None:
        dns_tup = cluster_info[0]
        cluster_name = cluster_info[1]
        key_name = cluster_info[2]

        for dns in dns_tup:
            print dns

        print "Cluster name: {}".format(cluster_name)

        write_dns(cluster_name, dns_tup)
        copy_pem(cluster_name, key_name)
    else:
        print "Cluster information not saved!"
