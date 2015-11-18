#!/usr/local/bin/python

from boto_util import BotoUtil, InstanceConfig
import argparse

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('region', help='region to search for instances')
    parser.add_argument('public_dns', nargs='+', help='list of all the public DNSs')


    args = parser.parse_args()

    BUtil = BotoUtil(args.region)

    public_dns_list = args.public_dns
    ips = map(lambda dns: ".".join(dns.split('.')[0].split('-')[1:]), public_dns_list)

    instance_ids = []
    request_ids = []
    for ip in ips:
        filters = {"ip-address": ip}
        instances = BUtil.conn.get_only_instances(filters=filters)
        if len(instances) > 0:
            instance_ids.append(instances[0].id)
            request_ids.append(instances[0].spot_instance_request_id)

    if len(instance_ids) > 0:
        print "{} terminating ...".format(instance_ids)
        BUtil.conn.terminate_instances(instance_ids=instance_ids)
    else:
        print "No instances with ips: {}".format(ips)

    if len(request_ids) > 0:
        print "{} spot requests cancelling ...".format(request_ids)
        BUtil.conn.cancel_spot_instance_requests(request_ids=request_ids)

