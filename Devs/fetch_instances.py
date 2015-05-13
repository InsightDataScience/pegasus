import boto.ec2
import argparse

def get_ec2_instances(region, instance_name):
    ec2_conn = boto.ec2.connect_to_region(region)
    instances = ec2_conn.get_only_instances(filters={"instance-state-name":"running", "tag:Name":instance_name})

    dns = []
    for i in instances:
        priv_name = str(i.private_dns_name).split(".")[0]
        pub_name = str(i.public_dns_name)
        dns.append((priv_name, pub_name))

    dns.sort()
    
    return dns

def write_dns(dns_tup):
    f_priv = open('private_dns','w')
    f_pub = open('public_dns','w')

    for pair in dns_tup:
        print(pair)
        f_priv.write(pair[0] + "\n")
        f_pub.write(pair[1] + "\n")

    f_priv.close()
    f_pub.close()

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('region', help='Region')
    parser.add_argument('instance_name', help='InstanceName')
    args = parser.parse_args()

    dns_tup = get_ec2_instances(args.region, args.instance_name)
    write_dns(dns_tup)
