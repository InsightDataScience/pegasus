#!/bin/bash

PEG_ROOT=$(dirname "${BASH_SOURCE}")

source ${PEG_ROOT}/aws_queries.sh

REM_USER=${REM_USER:=ubuntu}

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


function get_hostnames_with_name_and_role {
  local cluster_name=$1
  local cluster_role=$2
  local private_dns=($(get_private_dns_with_name_and_role ${cluster_name} ${cluster_role}))
  local hostnames=

  for dns in ${private_dns[@]}; do
    hostnames+=${dns%%.*}\ 
  done
  echo $hostnames
}

function store_public_dns {
  local cluster_name=$1
  local master_public_dns=($(get_public_dns_with_name_and_role ${cluster_name} master))
  local worker_public_dns=($(get_public_dns_with_name_and_role ${cluster_name} worker))
  local public_dns_path=${PEG_ROOT}/tmp/${cluster_name}/public_dns

  if [ -f ${public_dns_path} ]; then
    rm ${public_dns_path}
  fi

  # add master node if labeled first to public_dns_path
  if [ "${#master_public_dns[@]}" -eq "1" ]; then
    echo ${master_public_dns[0]} >> ${public_dns_path}
  fi

  # add workers
  for dns in ${worker_public_dns[@]}; do
    echo ${dns} >> ${public_dns_path}
  done
}

function store_hostnames {
  local cluster_name=$1
  local master_hostname=($(get_hostnames_with_name_and_role ${cluster_name} master))
  local worker_hostnames=($(get_hostnames_with_name_and_role ${cluster_name} worker))
  local hostnames_path=${PEG_ROOT}/tmp/${cluster_name}/hostnames

  if [ -f ${hostnames_path} ]; then
    rm ${hostnames_path}
  fi

  # add master node if labeled first to hostnames_path
  if [ "${#master_hostname[@]}" -eq "1" ]; then
    echo ${master_hostname[0]} >> ${hostnames_path}
  fi

  for hostname in ${worker_hostnames[@]}; do
    echo ${hostname} >> ${hostnames_path}
  done
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
    echo "pem keys in $1 are not identical!"
    echo "found ${unique_pemkeys}"
    exit 1
  fi

  pemkey_exists_locally ${unique_pemkeys}

  cp ~/.ssh/${unique_pemkeys}.pem ${PEG_ROOT}/tmp/${cluster_name}
}

function get_instance_type_histo_with_name {
  local cluster_name=$1
  get_instance_types_with_name ${cluster_name} | tr "\t" "\n" | sort | uniq -c
}

function describe_cluster {
  local cluster_name=$1
  local master_public_dns=($(get_public_dns_with_name_and_role ${cluster_name} master))
  local worker_public_dns=($(get_public_dns_with_name_and_role ${cluster_name} worker))
  local master_hostnames=($(get_hostnames_with_name_and_role ${cluster_name} master))
  local worker_hostnames=($(get_hostnames_with_name_and_role ${cluster_name} worker))
  local master_instance_ids=($(get_instance_ids_with_name_and_role ${cluster_name} master))
  local worker_instance_ids=($(get_instance_ids_with_name_and_role ${cluster_name} worker))

  get_instance_type_histo_with_name ${cluster_name}

  for index in ${!master_public_dns[@]}; do
    echo "MASTER NODE: ${master_instance_ids[$index]}"
    echo "    Hostname:   ${master_hostnames[$index]}"
    echo "    Public DNS: ${master_public_dns[$index]}"
  done

  for index in ${!worker_public_dns[@]}; do
    echo "WORKER NODE: ${worker_instance_ids[$index]}"
    echo "    Hostname:   ${worker_hostnames[$index]}"
    echo "    Public DNS: ${worker_public_dns[$index]}"
  done
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

function terminate_instances_with_name {
  local cluster_name=$1
  local instance_ids=$(get_instance_ids_with_name_and_role ${cluster_name})
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



function run_instances {
  local block_device_mappings="[{\"DeviceName\":\"/dev/sda1\",\"Ebs\":{\"DeleteOnTermination\":true,\"VolumeSize\":${vol_size:?"specify root volume size in GB"},\"VolumeType\":\"standard\"}}]"

  local monitoring="{\"Enabled\":false}"

  select_ami

  case "${purchase_type}" in
    spot)
      echo "[${tag_name}] requesting spot instances..."
      local spot_request_ids=$(run_spot_instances)

      tag_resources Name ${tag_name} ${spot_request_ids}

      echo "[${tag_name}] waiting for spot requests ${spot_request_ids} to be fulfilled..."
      wait_for_spot_requests ${spot_request_ids}

      INSTANCE_IDS=$(get_instance_ids_of_spot_request_ids ${spot_request_ids})
      ;;

    on_demand)
      INSTANCE_IDS=$(run_on_demand_instances)
      ;;

    *)
      echo "[${tag_name}] Invalid purchase type. Please select spot or on_demand."
      exit 1
      ;;
  esac

  tag_resources Name ${tag_name} ${INSTANCE_IDS}

  if [ ! -z ${role} ]; then
    tag_resources Role ${role} ${INSTANCE_IDS}
  fi

  echo "[${tag_name}] waiting for instances ${INSTANCE_IDS} in status ok state..."
  wait_for_instances_status_ok ${INSTANCE_IDS}

  echo "${INSTANCE_IDS} ready..."
}

function check_remote_folder {
  local pemloc=$1
  local remote_dns=$2
  local dependency_path=$3
  ssh -o "StrictHostKeyChecking no" -i ${pemloc} ${REM_USER}@${remote_dns} bash -c "'
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
    ${PEG_ROOT}/config/${TECHNOLOGY}/setup_cluster.sh ${PEMLOC} ${CLUSTER_NAME}
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
    ssh -i ${PEMLOC} ${REM_USER}@${dns} bash -c "'
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

function get_cluster_hostname_arr {
  local cluster_name=$1
  HOSTNAME_ARR=($(cat ${PEG_ROOT}/tmp/${cluster_name}/hostnames))
}

function get_cluster_privateip_arr {
  local cluster_name=$1
  PRIVATE_IP_ARR=($(cat ${PEG_ROOT}/tmp/${cluster_name}/hostnames | tr - . | cut -b 4-))
}

function get_cluster_publicdns_arr {
  local cluster_name=$1
  PUBLIC_DNS_ARR=($(cat ${PEG_ROOT}/tmp/${cluster_name}/public_dns))
}

function run_script_on_node {
  local pemloc=$1; shift
  local public_dns=$1; shift
  local script="$1"; shift
  local argin="$@"
  ssh -o "StrictHostKeyChecking no" -i ${pemloc} ${REM_USER}@${public_dns} 'bash -s' < "${script}" "${argin}"
}

function run_cmd_on_node {
  local pemloc=$1; shift
  local public_dns=$1; shift
  local cmd="$1"
  echo ${pemloc}
  echo ${public_dns}
  echo ${cmd}
  ssh -o "StrictHostKeyChecking no" -i ${pemloc} ${REM_USER}@${public_dns} '${cmd}'
}

function launch_more_workers_in {
  local cluster_name=$1
  local num=$2

  local worker_instance_ids=($(get_instance_ids_with_name_and_role ${cluster_name} worker))
  local template_id=${worker_instance_ids[0]}

  AWS_IMAGE=$(get_image_id_from_instances ${template_id})
  key_name=$(get_pem_key_from_instances ${template_id})
  security_group_ids=$(get_security_group_ids_from_instances ${template_id})
  instance_type=$(get_instance_type_from_instances ${template_id})
  subnet_id=$(get_subnet_id_from_instances ${template_id})
  vol_size=$(get_volume_size_from_instances ${template_id})
  tag_name=${cluster_name}
  num_instances=${num}
  role=worker

  local spot_request_id=$(get_spot_request_ids_of_instance_ids ${template_id})
  if [ -z ${spot_request_id} ]; then
    purchase_type=on_demand
  else
    purchase_type=spot
    price=$(get_price_of_spot_request_ids ${spot_request_id})
  fi

  run_instances
}
