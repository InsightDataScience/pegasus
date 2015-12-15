import boto.ec2
import boto
import json
import time
import os
import copy
import shutil

class BotoUtil(object):

    def __init__(self, region):
        self.conn = boto.ec2.connect_to_region(region)

    def create_ec2(self, IC):

        # set default EBS size
        dev_sda1 = boto.ec2.blockdevicemapping.BlockDeviceType()
        dev_sda1.size = IC.vol_size
        dev_sda1.delete_on_termination = True

        bdm = boto.ec2.blockdevicemapping.BlockDeviceMapping()
        bdm['/dev/sda1'] = dev_sda1

        if IC.purchase_type == 'spot':
            spot_requests = self.conn.request_spot_instances(
                price=IC.price,
                image_id=IC.image,
                placement=IC.az,
                subnet_id=IC.subnet,
                count=IC.num_instances,
                key_name=IC.key_name,
                security_group_ids=IC.security_group_ids,
                instance_type=IC.instance_type,
                block_device_map=bdm
                )

            time.sleep(30)

            # monitor spot instances for when they are satisfied
            request_ids = [sir.id for sir in spot_requests]
            self.wait_for_fulfillment(request_ids, copy.deepcopy(request_ids))

            time.sleep(10)

            for req_id in request_ids:
                self.conn.create_tags([req_id], {"Name":IC.tag_name})

            # check to see when all instance IDs have been assigned to spot requests
            fulfilled_spot_requests = self.conn.get_all_spot_instance_requests(request_ids=request_ids)
            instance_ids = [sir.instance_id for sir in fulfilled_spot_requests]

            reservations = self.conn.get_all_instances(instance_ids=instance_ids)

            instances = []
            for r in reservations:
                instances.extend(r.instances)


        elif IC.purchase_type == 'on_demand':
            image = self.conn.get_all_images(IC.image)
            reservations = image[0].run(placement=IC.az,
                subnet_id=IC.subnet,
                min_count=IC.num_instances,
                max_count=IC.num_instances,
                key_name=IC.key_name,
                security_group_ids=IC.security_group_ids,
                instance_type=IC.instance_type,
                block_device_map=bdm)

            instances = reservations.instances

        else:
            print "invalid purchase type: {}".format(IC.purchase_type)
            return


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

    def get_ec2_instances(self, cluster_name):
        instances = self.conn.get_only_instances(filters={"instance-state-name":"running", "tag:Name":"*{}*".format(cluster_name)})

        dns = []
        instance_type = {}
        pem_keys = []

        for i in instances:
            priv_name = str(i.private_dns_name).split(".")[0]
            pub_name = str(i.public_dns_name)
            dns.append((priv_name, pub_name))
            pem_keys.append(i.key_name)

            if i.instance_type in instance_type:
                instance_type[i.instance_type] += 1
            else:
                instance_type[i.instance_type] = 1

            print i.tags['Name'], i.key_name

        dns.sort()

        print json.dumps(instance_type, indent=2, sort_keys=True)

        if len(set(pem_keys)) == 1:
            return dns, i.tags['Name'], i.pem_keys
        else:
            "Instances in {} cluster do not have the same pem keys!".format(cluster_name)
            return

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

    def remove_cluster_info(self, cluster_name):
        cluster_info_path="tmp/{}".format(cluster_name)
        if os.path.exists(cluster_info_path):
            shutil.rmtree(cluster_info_path)

    def write_dns(self, cluster_name, dns_tup):
        cluster_info_path="tmp/{}".format(cluster_name)
        os.makedirs(cluster_info_path)

        f_priv = open('{}/private_dns'.format(cluster_info_path), 'w')
        f_pub = open('{}/public_dns'.format(cluster_info_path), 'w')

        for pair in dns_tup:
            f_priv.write(pair[0] + "\n")
            f_pub.write(pair[1] + "\n")

        f_priv.close()
        f_pub.close()

    def copy_pem(self, cluster_name, pem_name):
        cluster_info_path="tmp/{}".format(cluster_name)
        pem_key_loc = "{}/.ssh/{}.pem".format(os.path.expanduser("~"), pem_name)
        shutil.copy(pem_key_loc, cluster_info_path)

class InstanceConfig(object):

    def __init__(self, region, az, subnet, purchase_type, image, price,
        num_instances, key_name, security_group_ids, instance_type, tag_name,
        vol_size):
        self.region = region
        self.az = az
        self.subnet = subnet
        self.purchase_type= purchase_type
        self.image = image
        self.price = price
        self.num_instances = num_instances
        self.key_name = key_name
        self.security_group_ids = security_group_ids
        self.instance_type = instance_type
        self.tag_name = tag_name
        self.vol_size = vol_size

