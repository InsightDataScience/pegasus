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
#        image = self.conn.get_all_images("ami-df6a8b9b")

        dev_sda1 = boto.ec2.blockdevicemapping.BlockDeviceType()
        dev_sda1.size = 400
        dev_sda1.delete_on_termination = True

        bdm = boto.ec2.blockdevicemapping.BlockDeviceMapping()
        bdm['/dev/sda1'] = dev_sda1


        reservation = image[0].run(min_count=num_instances,
                                   max_count=num_instances,
                                   key_name=key_name,
                                   security_groups=security_groups,
                                   instance_type=instance_type,
                                   block_device_map=bdm)

        state_running = False

        while not state_running:
            print "Instance State: {} pending".format(tag_name)
            time.sleep(10)

            instance_state = []
            for instance in reservation.instances:
                instance_state.append(instance.state)
                instance.update()

            instance_state = all([instance.state==u'running' for instance in reservation.instances])

            statuses = self.conn.get_all_instance_status(instance_ids=[instance.id for instance in reservation.instances])
            if len(statuses)>0:
                instance_status = all([status.instance_status.status==u'ok' for status in statuses])
                system_status = all([status.system_status.status==u'ok' for status in statuses])
            else:
                instance_status = False
                system_status = False

#            print instance_state, instance_status, system_status
            state_running = instance_status and system_status and instance_state

        for instance in reservation.instances:
            self.conn.create_tags([instance.id], {"Name":tag_name})

        print "Instance State: {} running".format(tag_name)


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

