import boto.ec2
import boto
import json
import time
import os
import copy

class BotoUtil(object):

    def __init__(self, region):
        self.conn = boto.ec2.connect_to_region(region)
        self.s3_conn = boto.connect_s3()

    def create_ec2_spot(self, IC):

        # set default EBS size
        dev_sda1 = boto.ec2.blockdevicemapping.BlockDeviceType()
        dev_sda1.size = IC.vol_size
        dev_sda1.delete_on_termination = True

        bdm = boto.ec2.blockdevicemapping.BlockDeviceMapping()
        bdm['/dev/sda1'] = dev_sda1

        spot_requests = self.conn.request_spot_instances(price=IC.price,
                          image_id=IC.image, count=IC.num_instances,
                          key_name=IC.key_name, security_groups=IC.security_groups,
                          instance_type=IC.instance_type, block_device_map=bdm)

        # monitor spot instances for when they are satisfied
        request_ids = [sir.id for sir in spot_requests]
        self.wait_for_fulfillment(request_ids, copy.deepcopy(request_ids))

        for req_id in request_ids:
            self.conn.create_tags([req_id], {"Name":IC.tag_name})

        # check to see when all instance IDs have been assigned to spot requests
        fulfilled_spot_requests = self.conn.get_all_spot_instance_requests(request_ids=request_ids)
        instance_ids = [sir.instance_id for sir in fulfilled_spot_requests]

        reservations = self.conn.get_all_instances(instance_ids=instance_ids)

        instances = []
        for r in reservations:
            instances.extend(r.instances)

        # monitor when instances are ready to SSH
        state_running = False

        while not state_running:
            print "Instance State: {} pending".format(IC.tag_name)
            time.sleep(10)

            instance_state = []
            for instance in instances:
                instance_state.append(instance.state)
                instance.update()

            instance_state = all([inst.state==u'running' for inst in instances])

            statuses = self.conn.get_all_instance_status(instance_ids=[inst.id for inst in instances])

            instance_status = []
            system_status = []
            for stat in statuses:
                instance_status.append(stat.instance_status.status==u'ok')
                system_status.append(stat.system_status.status==u'ok')

            if len(statuses)>0:
                instance_ready = all(instance_status)
                system_ready = all(system_status)
            else:
                instance_ready = False
                system_ready = False

            state_running = instance_ready and system_ready and instance_state

        # give each instance a name
        for instance in instances:
            print instance.id
            self.conn.create_tags([instance.id], {"Name":IC.tag_name})

        print "Instance State: {} running".format(IC.tag_name)


    def create_ec2_instance(self, num_instances, key_name,
                            security_groups, instance_type, tag_name,
                            vol_size):

        # current image only valid for oregon AZ
        image = self.conn.get_all_images("ami-5189a661")

        # set default EBS size
        dev_sda1 = boto.ec2.blockdevicemapping.BlockDeviceType()
        dev_sda1.size = vol_size
        dev_sda1.delete_on_termination = True

        bdm = boto.ec2.blockdevicemapping.BlockDeviceMapping()
        bdm['/dev/sda1'] = dev_sda1

        # spin up instances
        reservation = image[0].run(min_count=num_instances,
                                   max_count=num_instances,
                                   key_name=key_name,
                                   security_groups=security_groups,
                                   instance_type=instance_type,
                                   block_device_map=bdm)

        # monitor when instances are ready to SSH
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

        # give each instance a name
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

    def wait_for_fulfillment(self, request_ids, pending_request_ids):
        """Loop through all pending request ids waiting for them to be fulfilled.
        If a request is fulfilled, remove it from pending_request_ids.
        If there are still pending requests, sleep and check again in 10 seconds.
        Only return when all spot requests have been fulfilled."""
        results = self.conn.get_all_spot_instance_requests(request_ids=pending_request_ids)
        for result in results:
            if result.status.code == 'fulfilled':
                pending_request_ids.pop(pending_request_ids.index(result.id))
                print "spot request `{}` fulfilled!".format(result.id)
        if len(pending_request_ids) == 0:
            print "all {} spots fulfilled!".format(len(request_ids))
        else:
            time.sleep(10)
            print "waiting on {} requests".format(len(pending_request_ids))
            self.wait_for_fulfillment(request_ids, pending_request_ids)


    def write_dns(self, instance_name, dns_tup):
        os.makedirs("tmp/{}".format(instance_name))
        f_priv = open('tmp/{}/private_dns'.format(instance_name), 'w')
        f_pub = open('tmp/{}/public_dns'.format(instance_name), 'w')

        for pair in dns_tup:
            print(pair)
            f_priv.write(pair[0] + "\n")
            f_pub.write(pair[1] + "\n")

        f_priv.close()
        f_pub.close()

    def fetch_tech_ver(self, tech_name, version, dest_folder=None):
        bucket_name = "apache-repo"
        bucket = self.s3_conn.get_bucket(bucket_name)
        prefix = os.path.join(tech_name, version, tech_name)
        keys = bucket.list(prefix=prefix)

        for key in keys:
            print key.name
            filename = key.name.split('/')[-1]
            localpath = os.path.join(dest_folder, filename)
            if dest_folder:
                key.get_contents_to_filename(localpath)

class InstanceConfig(object):

    def __init__(self, region='us-west-2',
                       image='ami-5189a661',
                       price=0.04,
                       num_instances=4,
                       key_name='insight-cluster',
                       security_groups=["open"],
                       instance_type='m4.xlarge',
                       tag_name='test-cluster',
                       vol_size=100):
        self.region = region
        self.image = image
        self.price = price
        self.num_instances = num_instances
        self.key_name = key_name
        self.security_groups = security_groups
        self.instance_type = instance_type
        self.tag_name = tag_name
        self.vol_size = vol_size

