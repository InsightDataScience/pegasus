#!/bin/bash

PEG_ROOT=$(dirname "${BASH_SOURCE}")

AWS_CMD="aws ec2 --region ${REGION:=us-west-2} --output text"

ROOT_DISK_TYPE=${ROOT_DISK_TYPE:-standard}
ROOT_DISK_SIZE=${ROOT_DISK_SIZE:-400}

BLOCK_DEVICE_MAPPINGS="[{\"DeviceName\":\"/dev/sda1\",\"Ebs\":{\"DeleteOnTermination\":true,\"VolumeSize\":${ROOT_DISK_SIZE},\"VolumeType\":\"${ROOT_DISK_TYPE}\"}}]"

function parse_yaml {
  local prefix=$2
  local s='[[:space:]]*' w='[a-zA-Z0-9_]*' fs=$(echo @|tr @ '\034')
  sed -ne "s|^\($s\)\($w\)$s:$s\"\(.*\)\"$s\$|\1$fs\2$fs\3|p" \
      -e "s|^\($s\)\($w\)$s:$s\(.*\)$s\$|\1$fs\2$fs\3|p"  $1 |
  awk -F$fs '{
      indent = length($1)/2;
      vname[indent] = $2;
      for (i in vname) {if (i > indent) {delete vname[i]}}
      if (length($3) > 0) {
        vn=""; for (i=0; i<indent; i++) {vn=(vn)(vname[i])("_")}
        printf("%s%s%s=\"%s\"\n", "'$prefix'",vn, $2, $3);
      }
  }'
}

function get_public_dns_with_name {
  local cluster_name=$1
  ${AWS_CMD} describe-instances \
    --filters Name=tag:Name,Values=${cluster_name} \
    --query Reservations[].Instances[].NetworkInterfaces[].Association.PublicDnsName
}

function get_private_dns_with_name {
  local cluster_name=$1
  ${AWS_CMD} describe-instances \
    --filters Name=tag:Name,Values=${cluster_name} \
    --query Reservations[].Instances[].NetworkInterfaces[].PrivateDnsName
}

function get_hostnames_with_name {
  local cluster_name=$1
  local private_dns=($(get_private_dns_with_name ${cluster_name}))
  local hostnames=

  for dns in ${private_dns[@]}; do
    hostnames+=${dns%%.*}\ 
  done
  echo $hostnames
}

function store_public_dns {
  local cluster_name=$1
  local public_dns=($(get_public_dns_with_name ${cluster_name}))
  local public_dns_path=${PEG_ROOT}/tmp/${cluster_name}/public_dns

  rm ${public_dns_path}
  for dns in ${public_dns[@]}; do
    echo ${dns} >> ${public_dns_path}
  done
}

function store_hostnames {
  local cluster_name=$1
  local hostnames=($(get_hostnames_with_name ${cluster_name}))
  local hostnames_path=${PEG_ROOT}/tmp/${cluster_name}/hostnames

  rm ${hostnames_path}
  for hostname in ${hostnames[@]}; do
    echo ${hostname} >> ${hostnames_path}
  done
}

function get_pemkey_with_name {
  local cluster_name=$1
  ${AWS_CMD} describe-instances \
    --filters Name=tag:Name,Values=${cluster_name} \
    --query Reservations[].Instances[].KeyName
}

function get_unique_pemkey {
  local cluster_name=$1
  get_pemkey_with_name ${cluster_name} | tr "\t" "\n" | sort -u
}

function pemkey_exists_locally {
  local pemkey_name=$1
  if [ ! -f ~/.ssh/${pemkey_name}.pem ]; then
    echo "pem key ${pemkey_name} does not exists locally in ~/.ssh/"
    exit 1
  fi
}

function store_pemkey {
  local cluster_name=$1
  local unique_pemkeys=$(get_unique_pemkey ${cluster_name})
  local num_unique_pemkeys=$(echo ${unique_pemkeys} | wc -w)

  # check if pem keys are unique in cluster
  if [ ${num_unique_pemkeys} -ne 1 ]; then
    echo "pem keys in $1 are not unique!"
    echo "found ${unique_pemkeys}"
    exit 1
  fi

  pemkey_exists_locally ${unique_pemkeys}

  cp ~/.ssh/${unique_pemkeys}.pem ${PEG_ROOT}/tmp/${cluster_name}
}

function get_instance_names_with_name {
  local cluster_name=$1
  ${AWS_CMD} describe-instances \
    --filters Name=tag:Name,Values=${cluster_name} \
    --query Reservations[].Instances[].Tags[?key=='Name'].Value
}

function get_instance_types_with_name {
  local cluster_name=$1
  ${AWS_CMD} describe-instances \
    --filters Name=tag:Name,Values=${cluster_name} \
    --query Reservations[].Instances[].InstanceType
}

function get_instance_type_histo_with_name {
  local cluster_name=$1
  get_instance_types_with_name ${cluster_name} | tr "\t" "\n" | sort | uniq -c
}

function describe_cluster {
  local cluster_name=$1
  local public_dns=($(get_public_dns_with_name ${cluster_name}))
  local hostnames=($(get_hostnames_with_name ${cluster_name}))
  local instance_names=($(get_instance_names_with_name ${cluster_name}))
  local pemkeys=($(get_pemkey_with_name ${cluster_name}))
  local num_instances=${#hostnames[@]}

  for index in ${!pemkeys[@]}; do
    echo "Instance name ${instance_names[$index]} using ${pemkeys[$index]} key"
  done

  get_instance_type_histo_with_name ${cluster_name}

  echo "${num_instances} instances found in ${REGION:=us-west-2} with the name ${cluster_name}"

  local first_one=1
  for index in ${!hostnames[@]}; do
    if [ ${first_one} -eq 1 ]; then
      echo "MASTER NODE:"
      echo "    Hostname:   ${hostnames[$index]}"
      echo "    Public_DNS: ${public_dns[$index]}"
      first_one=0
    else
      echo "WORKER NODE:"
      echo "    Hostname:   ${hostnames[$index]}"
      echo "    Public_DNS: ${public_dns[$index]}"
    fi
  done
}

function show_all_vpcs {
  ${AWS_CMD} describe-vpcs \
    --output json \
    --query Vpcs[]
}

function get_vpcids_with_name {
  local vpc_name=$1
  ${AWS_CMD} describe-vpcs \
    --filters Name=tag:Name,Values=${vpc_name} \
    --query Vpcs[].VpcId
}

function show_all_subnets_in_vpc {
  local vpc_name=$1
  local vpc_id=$(get_vpcids_with_name ${vpc_name})

  ${AWS_CMD} describe-subnets \
    --output json \
    --filters Name=vpc-id,Values=${vpc_id:?"vpc ${vpc_name} not found"} \

}
function show_all_security_groups_in_vpc {
  local vpc_name=$1
  local vpc_id=$(get_vpcids_with_name ${vpc_name})

  ${AWS_CMD} describe-security-groups \
    --output json \
    --filters Name=vpc-id,Values=${vpc_id:?"vpc ${vpc_name} not found"} \
    --query SecurityGroups[]
}

function get_security_groupids_in_vpc_with_name {
  local vpc_name=$1
  local vpc_id=$(get_vpcids_with_name ${vpc_name})
  local security_group_name=$2

  ${AWS_CMD} describe-security-groups \
    --filters Name=vpc-id,Values=${vpc_id:?"vpc ${vpc_name} not found"} \
              Name=group-name,Values=${security_group_name} \
    --query SecurityGroups[].GroupId
}

function set_launch_config {
  local template_file=$1
  eval $(parse_yaml ${template_file})
}

function select_ami {
  case "${REGION}" in
    us-west-2)
      aws_image=ami-4342a723
      ;;

    us-west-1)
      aws_image=ami-cb97e3ab
      ;;

    us-east-1)
      aws_image=ami-a20d2bc8
      ;;

    *)
      echo "unrecognized AWS region"
      exit 1
  esac
}

function run_spot_instances {
  # TODO
  echo "asdf"
}

function run_on_demand_instances {
  local monitoring="{\"Enabled\":false}"

  select_ami

  ${AWS_CMD} run-instances \
    --count ${num_instances:?"specify number of instances"} \
    --image-id ${aws_image} \
    --key-name ${key_name:?"specify pem key to use"} \
    --security-group-ids ${security_group_ids:?"specify security group ids"} \
    --instance-type ${instance_type:?"specify instance type"} \
    --subnet-id ${subnet_id:?"specify subnet id to launch"} \
    --block-device-mappings ${BLOCK_DEVICE_MAPPINGS} \
    --monitoring ${monitoring} \
    --query Instances[].InstanceId

}

function tag_instances {
  local tag_name=$1; shift
  local instance_ids="$@"
  ${AWS_CMD} create-tags \
    --resources ${instance_ids} \
    --tags Key=Name,Value=${tag_name}
}

function wait_for_instances_status_ok {
  local instance_ids="$@"
  ${AWS_CMD} wait instance-status-ok \
    --instance-ids ${instance_ids}
}
