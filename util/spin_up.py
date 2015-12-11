#!/usr/local/bin/python

from boto_util import BotoUtil, InstanceConfig
import argparse
import json
from pprint import pprint

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('template_path', help='path to instance template')
    args = parser.parse_args()

    with open(args.template_path) as json_file:
        params = json.load(json_file)


    BUtil = BotoUtil(params["region"])
    IConf = InstanceConfig(purchase_type=params["purchase_type"],
                           region=params["region"],
                           az=params["az"],
                           subnet=params["subnet"],
                           image=params["image"],
                           price=params["price"],
                           num_instances=params["num_instances"],
                           key_name=params["key_name"],
                           security_group_ids=params["security_group_ids"],
                           instance_type=params["instance_type"],
                           tag_name=params["tag_name"],
                           vol_size=params["vol_size"])

    BUtil.create_ec2(IConf)

    dns_tup, cluster_name = BUtil.get_ec2_instances(params["tag_name"])
    BUtil.write_dns(params["tag_name"], dns_tup)


