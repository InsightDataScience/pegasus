import boto.ec2
import json
import time
import os

class BotoUtil(object):

    def __init__(self, region):
        self.conn = boto.ec2.connect_to_region(region)


    def create_ec2_instance(self, num_instances, key_name,
                            security_groups, instance_type, tag_name):

        image = self.conn.get_all_images("ami-5189a661")

        reservation = image[0].run(min_count=num_instances,
                                   max_count=num_instances,
                                   key_name=key_name,
                                   security_groups=security_groups,
                                   instance_type=instance_type)

        for instance in reservation.instances:
            self.conn.create_tags([instance.id], {"Name":tag_name})

        while instance.state == u'pending':
            print "Instance State: {} {}".format(tag_name, instance.state)
            time.sleep(5)
            instance.update()

        print "Instance State: {} {}".format(tag_name, instance.state)


    def get_ec2_instances(self, instance_name):
        instances = self.conn.get_only_instances(filters={"instance-state-name":"running", "tag:Name":"*{}*".format(instance_name)})

        dns = []
        instance_type = {}

        for i in instances:
            priv_name = str(i.private_dns_name).split(".")[0]
            pub_name = str(i.public_dns_name)
            dns.append((priv_name, pub_name))

            if i.instance_type in instance_type:
                instance_type[i.instance_type] += 1
            else:
                instance_type[i.instance_type] = 1

            print i.tags['Name']

        dns.sort()

        print json.dumps(instance_type, indent=2, sort_keys=True)

        return dns

    def write_dns(self, instance_name, dns_tup):
        os.makedirs(instance_name)
        f_priv = open('{}/private_dns'.format(instance_name), 'w')
        f_pub = open('{}/public_dns'.format(instance_name), 'w')

        for pair in dns_tup:
            print(pair)
            f_priv.write(pair[0] + "\n")
            f_pub.write(pair[1] + "\n")

        f_priv.close()
        f_pub.close()

