#!/usr/local/bin/python

import argparse
from util.boto_util import BotoUtil

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('region', help='region to search for instances')
    parser.add_argument('public_dns', nargs='+', help='list of all the public DNSs')


    args = parser.parse_args()

    BUtil = BotoUtil(args.region)

    public_dns_list = args.public_dns
    ips = [".".join(dns.split('.')[0].split('-')[1:]) for dns in  public_dns_list]

    BUtil.terminate_cluster(ips)
