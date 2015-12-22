#!/usr/local/bin/python

import argparse
import json
from util.boto_util import BotoUtil, InstanceConfig

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('template_path', help='path to instance template')
    args = parser.parse_args()

    with open(args.template_path) as json_file:
        params = json.load(json_file)


    BUtil = BotoUtil(params['region'])
    IConf = InstanceConfig(params)

    if IConf.is_valid():
        BUtil.launch_instances(IConf)


