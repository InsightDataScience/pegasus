#!/bin/bash

PEG_ROOT=$(dirname "${BASH_SOURCE}")

AWS_CMD="aws ec2 --region ${REGION:=us-west-2} --output text"

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

  if [ -f ${public_dns_path} ]; then
    rm ${public_dns_path}
  fi

  for dns in ${public_dns[@]}; do
    echo ${dns} >> ${public_dns_path}
  done
}

function store_hostnames {
  local cluster_name=$1
  local hostnames=($(get_hostnames_with_name ${cluster_name}))
  local hostnames_path=${PEG_ROOT}/tmp/${cluster_name}/hostnames

  if [ -f ${hostnames_path} ]; then
    rm ${hostnames_path}
  fi

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
      AWS_IMAGE=ami-4342a723
      ;;

    us-west-1)
      AWS_IMAGE=ami-cb97e3ab
      ;;

    us-east-1)
      AWS_IMAGE=ami-a20d2bc8
      ;;

    *)
      echo "unrecognized AWS region"
      exit 1
  esac
}

function run_spot_instances {
  local launch_specification="{\"ImageId\":\"${AWS_IMAGE}\",\"KeyName\":\"${key_name}\",\"InstanceType\":\"${instance_type}\",\"BlockDeviceMappings\":${block_device_mappings},\"SubnetId\":\"${subnet_id}\",\"Monitoring\":${monitoring},\"SecurityGroupIds\":[\"${security_group_ids}\"]}"

  ${AWS_CMD} request-spot-instances \
    --spot-price "${price:?"specify spot price"}" \
    --instance-count ${num_instances:?"specify number of instances"} \
    --type "one-time" \
    --launch-specification ${launch_specification} \
    --query SpotInstanceRequests[].SpotInstanceRequestId

}

function run_on_demand_instances {
  ${AWS_CMD} run-instances \
    --count ${num_instances:?"specify number of instances"} \
    --image-id ${AWS_IMAGE} \
    --key-name ${key_name:?"specify pem key to use"} \
    --security-group-ids ${security_group_ids:?"specify security group ids"} \
    --instance-type ${instance_type:?"specify instance type"} \
    --subnet-id ${subnet_id:?"specify subnet id to launch"} \
    --block-device-mappings ${block_device_mappings} \
    --monitoring ${monitoring} \
    --query Instances[].InstanceId
}

function tag_name_of_resources {
  local tag_name=$1; shift
  local resource_ids="$@"
  ${AWS_CMD} create-tags \
    --resources ${resource_ids} \
    --tags Key=Name,Value=${tag_name}
}

function wait_for_instances_status_ok {
  local instance_ids="$@"
  ${AWS_CMD} wait instance-status-ok \
    --instance-ids ${instance_ids}
}

function wait_for_spot_requests {
  local spot_request_ids="$@"
  ${AWS_CMD} wait spot-instance-request-fulfilled \
    --spot-instance-request-ids ${spot_request_ids}
}

function get_instance_ids_of_spot_request_ids {
  local spot_request_ids="$@"
  ${AWS_CMD} describe-spot-instance-requests \
    --spot-instance-request-ids ${spot_request_ids} \
    --query SpotInstanceRequests[].InstanceId
}

function get_instance_ids_with_name {
  local cluster_name=$1
  ${AWS_CMD} describe-instances \
    --filters Name=tag:Name,Values=${cluster_name} \
    --query Reservations[].Instances[].InstanceId
}

function get_spot_request_ids_of_instance_ids {
  local instance_ids="$@"
  ${AWS_CMD} describe-instances \
    --instance-ids ${instance_ids} \
    --query Reservations[].Instances[].SpotInstanceRequestId
}

function terminate_instances_with_name {
  local cluster_name=$1
  local instance_ids=$(get_instance_ids_with_name ${cluster_name})
  local spot_request_ids=$(get_spot_request_ids_of_instance_ids ${instance_ids})
  local num_instances=$(echo ${instance_ids} | wc -w)
  local num_spot_requests=$(echo ${spot_request_ids} | wc -w)

  if [[ "${num_instances}" -gt "0" ]]; then
    echo "terminating instances: ${instance_ids}"
    ${AWS_CMD} terminate-instances \
      --instance-ids ${instance_ids}

    if [[ "${num_spot_requests}" -gt "0" ]]; then
      echo "cancelling spot requests: ${spot_request_ids}"
      ${AWS_CMD} cancel-spot-instance-requests \
        --spot-instance-request-ids ${spot_request_ids}
    fi
  fi
}

function retag_instance_with_name {
  local cluster_name=$1
  local new_cluster_name=$2
  local instance_ids=$(get_instance_ids_with_name ${cluster_name})

  ${AWS_CMD} create-tags \
    --resources ${instance_ids} \
    --tags Key=Name,Value=${new_cluster_name}
}

function run_instances {
  local block_device_mappings="[{\"DeviceName\":\"/dev/sda1\",\"Ebs\":{\"DeleteOnTermination\":true,\"VolumeSize\":${vol_size:?"specify root volume size in GB"},\"VolumeType\":\"standard\"}}]"

  local monitoring="{\"Enabled\":false}"

  select_ami

  case "${purchase_type}" in
    spot)
      echo "[${tag_name}] requesting spot instances..."
      local spot_request_ids=$(run_spot_instances)

      tag_name_of_resources ${tag_name} ${spot_request_ids}

      echo "[${tag_name}] waiting for spot requests ${spot_request_ids} to be fulfilled..."
      wait_for_spot_requests ${spot_request_ids}

      local instance_ids=$(get_instance_ids_of_spot_request_ids ${spot_request_ids})
      ;;

    on_demand)
      local instance_ids=$(run_on_demand_instances)
      ;;

    *)
      echo "[${tag_name}] Invalid purchase type. Please select spot or on_demand."
      exit 1
      ;;
  esac

  tag_name_of_resources ${tag_name} ${instance_ids}

  echo "[${tag_name}] waiting for instances ${instance_ids} in status ok state..."
  wait_for_instances_status_ok ${instance_ids}

  echo "${instance_ids} ready..."
}

function check_remote_folder {
  local pemloc=$1
  local remote_dns=$2
  local dependency_path=$3
  ssh -o "StrictHostKeyChecking no" -i ${pemloc} ubuntu@${remote_dns} bash -c "'
    if [ -d ${dependency_path} ]; then
      echo "installed"
    else
      echo "missing"
    fi
    '"
}

function install_tech {
  if [ -z "${DEP}" ]; then
    echo "Installing ${TECHNOLOGY} on ${CLUSTER_NAME}"
    ${PEG_ROOT}/install/cluster_download ${PEMLOC} ${CLUSTER_NAME} ${TECHNOLOGY}
    ${PEG_ROOT}config/${TECHNOLOGY}/setup_cluster.sh ${PEMLOC} ${CLUSTER_NAME}
  else
    INSTALLED=$(check_remote_folder ${PEMLOC} ${MASTER_DNS} ${DEP_ROOT_FOLDER}${DEP})
    if [ "${INSTALLED}" = "installed" ]; then
      DEP=(${DEP[@]:1})
      echo ${DEP}
      install_tech
    else
      echo "${DEP} is not installed in ${DEP_ROOT_FOLDER}"
      echo "Please install ${DEP} and then proceed with ${TECHNOLOGY}"
      echo "peg install ${CLUSTER_NAME} ${TECHNOLOGY}"
      exit 1
    fi
  fi
}

function get_dependencies {
  while read line; do
    KEY_RAW=$(echo $line | awk '{print $1}')
    KEY=${KEY_RAW%?}
    VALUE=$(echo $line | awk '{print $2}')
    if [ "$KEY" == "$TECHNOLOGY" ]; then
      if [ -z $VALUE ]; then
        DEP=()
        break
      else
        DEP_RAW=${VALUE/,/ }
        DEP=($DEP_RAW)
      fi
    fi
  done < ${PEG_ROOT}/dependencies.txt
}

function uninstall_tech {
  for dns in ${PUBLIC_DNS[@]}; do
    echo ${dns}
    ssh -i ${PEMLOC} ubuntu@${dns} bash -c "'
      sudo rm -rf /usr/local/${TECHNOLOGY}
      sed -i \"/$(echo ${TECHNOLOGY} | tr a-z A-Z)/d\" ~/.profile
    '"
  done
}

function service_action {
  INSTALLED=$(check_remote_folder ${PEMLOC} ${MASTER_DNS} ${ROOT_FOLDER}${TECHNOLOGY})
  if [ "${INSTALLED}" = "installed" ]; then
    case ${ACTION} in
      start)
        ${PEG_ROOT}/service/${TECHNOLOGY}/start_service.sh ${PEMLOC} ${CLUSTER_NAME}
        ;;
      stop)
        ${PEG_ROOT}/service/${TECHNOLOGY}/stop_service.sh ${PEMLOC} ${CLUSTER_NAME}
        ;;
      *)
        echo -e "Invalid action for ${TECHNOLOGY}"
        exit 1
        ;;
    esac
  else
    echo "${TECHNOLOGY} is not installed in ${ROOT_FOLDER}"
    exit 1
  fi
}


