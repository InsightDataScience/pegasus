import argparse
from boto_util import BotoUtil, remove_cluster_info, write_dns, copy_pem

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('region', help='Region')
    parser.add_argument('cluster_name', help='Cluster Name')
    parser.add_argument('new_tag_name', help='New Cluster Name')

    args = parser.parse_args()

    BUtil = BotoUtil(args.region)

    BUtil.retag_cluster(args.cluster_name, args.new_tag_name)

    cluster_info = BUtil.fetch_instances(args.new_tag_name)

    if cluster_info is not None:
        dns_tup = cluster_info[0]
        cluster_name = cluster_info[1]
        key_name = cluster_info[2]

        for idx, dns in enumerate(dns_tup):
            if idx == 0:
                print "{} NODE: Hostname:{}, Public DNS:{}".format("MASTER", dns[0], dns[1])
            else:
                print "{} NODE: Hostname:{}, Public DNS:{}".format("WORKER", dns[0], dns[1])

        print "Cluster name: {}".format(cluster_name)

        write_dns(cluster_name, dns_tup)
        copy_pem(cluster_name, key_name)
    else:
        print "Cluster information not saved!"
