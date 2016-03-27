#!/bin/bash

PEG_ROOT=$(dirname "${BASH_SOURCE}")

source ${PEG_ROOT}/colors.sh
source ${PEG_ROOT}/aws-queries.sh

REM_USER=${REM_USER:=ubuntu}

# thanks to pkuczynski @ https://gist.github.com/pkuczynski/8665367
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

function validate_template {
  if [ -z ${purchase_type} ]; then
    echo "must specify purchase_type: spot or on_demand"
    exit 1
  elif [ "${purchase_type}" != "spot" ] && [ "${purchase_type}" != "on_demand" ]; then
    echo "must specify spot or on_demand for purchase_type"
    exit 1
  fi

  if [ -z ${subnet_id} ]; then
    echo "must specify subnet_id"
    exit 1
  elif [[ ${subnet_id} != subnet-* ]]; then
    echo "invalid subnet_id pattern: e.g. subnet-12345"
    exit 1
  fi

  if [ -z ${num_instances} ]; then
    echo "must specify num_instances"
    exit 1
  fi

  if [ -z ${key_name} ]; then
    echo "must specify key_name"
    exit
  fi

  if [ -z ${security_group_ids} ]; then
    echo "must specify security_group_ids"
    exit 1
  elif [[ ${security_group_ids} != sg-* ]]; then
    echo "invalid security_group_ids pattern: e.g. sg-1a2b345"
    exit 1
  fi

  if [ -z ${instance_type} ]; then
    echo "must specify instance_type"
    exit 1
  fi

  if [ -z ${tag_name} ]; then
    echo "must specify tag_name"
    exit 1
  fi

  if [ -z ${role} ]; then
    echo "must specify role: master or worker"
    exit 1
  elif [ "${role}" != "master" ] && [ "${role}" != "worker" ]; then
    echo "must specify master or worker for role"
    exit 1
  fi

  if [ "${purchase_type}" == "spot" ]; then
    if [ -z "${price}" ]; then
      echo "must specify price when requesting spot purchase_type"
      exit 1
    fi
  fi

}

function get_hostnames_with_name_and_role {
  local cluster_name=$1
  local cluster_role=$2
  local private_dns=($(get_private_dns_with_name_and_role ${cluster_name} ${cluster_role}))
  local hostnames=

  for dns in ${private_dns[@]}; do
    hostnames+=${dns%%.*}\ 
  done
  echo ${hostnames}
}

function store_public_dns {
  local cluster_name=$1
  local master_public_dns=($(get_public_dns_with_name_and_role ${cluster_name} master))
  local worker_public_dns=($(get_public_dns_with_name_and_role ${cluster_name} worker))
  local public_dns_path=${PEG_ROOT}/tmp/${cluster_name}/public_dns

  if [ -f ${public_dns_path} ]; then
    rm ${public_dns_path}
  fi

  touch ${public_dns_path}

  # add master node if labeled first to public_dns_path
  for dns in ${master_public_dns[@]}; do
    echo ${dns} >> ${public_dns_path}
  done

  # add workers
  for dns in ${worker_public_dns[@]}; do
    echo ${dns} >> ${public_dns_path}
  done
}

function store_roles {
  local cluster_name=$1
  local master_public_dns=($(get_public_dns_with_name_and_role ${cluster_name} master))
  local worker_public_dns=($(get_public_dns_with_name_and_role ${cluster_name} worker))
  local roles_path=${PEG_ROOT}/tmp/${cluster_name}/roles

  if [ -f ${roles_path} ]; then
    rm ${roles_path}
  fi

  touch ${roles_path}

  # add master node if labeled first to public_dns_path
  for dns in ${master_public_dns[@]}; do
    echo "master" >> ${roles_path}
  done

  # add workers
  for dns in ${worker_public_dns[@]}; do
    echo "worker" >> ${roles_path}
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

  touch ${hostnames_path}

  # add master node if labeled to hostnames_path
  for hostname in ${master_hostname[@]}; do
    echo ${hostname} >> ${hostnames_path}
  done

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

  chmod 600 ~/.ssh/${unique_pemkeys}.pem
  cp ~/.ssh/${unique_pemkeys}.pem ${PEG_ROOT}/tmp/${cluster_name}

  ssh-add ${PEG_ROOT}/tmp/${cluster_name}/${unique_pemkeys}.pem > /dev/null 2>&1
  echo "${unique_pemkeys}.pem has been added to your ssh-agent"
}

function get_instance_type_histo_with_name {
  local cluster_name=$1
  get_instance_types_with_name ${cluster_name} | tr "\t" "\n" | sort | uniq -c
}

function describe_cluster {
  local cluster_name=$1
  local public_dns=($(fetch_cluster_public_dns ${cluster_name}))
  local hostnames=($(fetch_cluster_hostnames ${cluster_name}))
  local roles=($(fetch_cluster_roles ${cluster_name}))

  echo -e "${color_blue}${cluster_name}${color_norm} cluster instance type histogram"
  get_instance_type_histo_with_name ${cluster_name}

  echo ""
  for index in ${!public_dns[@]}; do
    if [ "${roles[$index]}" == "master" ]; then
      echo -e "${color_green}MASTER NODE${color_norm}:"
      echo "    Hostname:   ${hostnames[$index]}"
      echo -e "    Public DNS: ${public_dns[$index]}\n"
    elif [ "${roles[$index]}" == "worker" ]; then
      echo -e "${color_yellow}WORKER NODE${color_norm}:"
      echo "    Hostname:   ${hostnames[$index]}"
      echo -e "    Public DNS: ${public_dns[$index]}\n"
    fi
  done

  local num_masters=$(fetch_cluster_num_masters ${cluster_name})
  local num_workers=$(fetch_cluster_num_workers ${cluster_name})

  if [ -z ${num_masters} ] || [ "${num_masters}" -eq "0" ]; then
    echo -e "WARNING: no master found in cluster ${color_blue}${cluster_name}${color_norm}"
  elif [ "${num_masters}" -gt "1" ]; then
    echo -e "WARNING: more than one master found in cluster ${color_blue}${cluster_name}${color_norm}"
  fi

  if [ -z ${num_workers} ] || [ "${num_workers}" -eq "0" ]; then
    echo -e "WARNING: no workers found in cluster ${color_blue}${cluster_name}${color_norm}"
  fi
}

function set_launch_config {
  local template_file=$1
  eval $(parse_yaml ${template_file})
}

function select_ami {
  case "${AWS_DEFAULT_REGION}" in
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
      tag_resources Owner ${USER} ${spot_request_ids}


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
  tag_resources Owner ${USER} ${INSTANCE_IDS}

  if [ ! -z ${role} ]; then
    tag_resources Role ${role} ${INSTANCE_IDS}
  fi

  echo "[${tag_name}] waiting for instances ${INSTANCE_IDS} in status ok state..."
  wait_for_instances_status_ok ${INSTANCE_IDS}

  echo "[${tag_name}] ${INSTANCE_IDS} ready..."
}

function check_remote_folder {
  local remote_dns=$1
  local dependency_path=$2
  ssh -A -o "StrictHostKeyChecking no" ${REM_USER}@${remote_dns} bash -c "'
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
    ${PEG_ROOT}/install/cluster_download ${CLUSTER_NAME} ${TECHNOLOGY}
    ${PEG_ROOT}/config/${TECHNOLOGY}/setup_cluster.sh ${CLUSTER_NAME}
  else
    INSTALLED=$(check_remote_folder ${MASTER_DNS} ${DEP_ROOT_FOLDER}${DEP})
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
    ssh -A ${REM_USER}@${dns} bash -c "'
      sudo rm -rf /usr/local/${TECHNOLOGY}
      sed -i \"/$(echo ${TECHNOLOGY} | tr a-z A-Z)/d\" ~/.profile
    '"
  done
}

function service_action {
  INSTALLED=$(check_remote_folder ${MASTER_DNS} ${ROOT_FOLDER}${TECHNOLOGY})
  if [ "${INSTALLED}" = "installed" ]; then
    case ${ACTION} in
      start)
        ${PEG_ROOT}/service/${TECHNOLOGY}/start_service.sh ${CLUSTER_NAME}
        ;;
      stop)
        ${PEG_ROOT}/service/${TECHNOLOGY}/stop_service.sh ${CLUSTER_NAME}
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

function run_script_on_node {
  local public_dns=$1; shift
  local script="$1"; shift
  local argin="$@"
  ssh -A -o "StrictHostKeyChecking no" ${REM_USER}@${public_dns} 'bash -s' < "${script}" "${argin}"
}

function run_cmd_on_node {
  local public_dns=$1; shift
  local cmd="$@"
  ssh -A -o "StrictHostKeyChecking no" ${REM_USER}@${public_dns} ${cmd}
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

function run_cmd_on_file {
  local filename=$1; shift
  local cmd="$@";

  if [ -f ${filename} ]; then
    eval ${cmd}
  fi

}

function fetch_public_dns_of_node_in_cluster {
  local cluster_name=$1
  local cluster_num=$2
  local filename=${PEG_ROOT}/tmp/${cluster_name}/public_dns
  local cmd='sed -n "${cluster_num}{p;q;}" ${filename}'
  run_cmd_on_file ${filename} ${cmd}
}

function fetch_hostname_of_node_in_cluster {
  local cluster_name=$1
  local cluster_num=$2
  local filename=${PEG_ROOT}/tmp/${cluster_name}/hostnames
  local cmd='sed -n "${cluster_num}{p;q;}" ${filename}'
  run_cmd_on_file ${filename} ${cmd}
}

function fetch_private_ip_of_node_in_cluster {
  local cluster_name=$1
  local cluster_num=$2
  local filename=${PEG_ROOT}/tmp/${cluster_name}/hostnames
  local cmd='sed -n "${cluster_num}{p;q;}" ${filename} | tr - . | cut -b 4-'
  run_cmd_on_file ${filename} ${cmd}
 }

function fetch_cluster_master_public_dns {
  local cluster_name=$1
  local filename=${PEG_ROOT}/tmp/${cluster_name}/public_dns
  local cmd='head -n 1 ${filename}'
  run_cmd_on_file ${filename} ${cmd}
}

function fetch_cluster_worker_public_dns {
  local cluster_name=$1
  local filename=${PEG_ROOT}/tmp/${cluster_name}/public_dns
  local cmd='tail -n +2 ${filename}'
  run_cmd_on_file ${filename} ${cmd}
}

function fetch_cluster_master_private_ip {
  local cluster_name=$1
  local filename=${PEG_ROOT}/tmp/${cluster_name}/hostnames
  local cmd='head -n 1 ${filename} | tr - . | cut -b 4-'
  run_cmd_on_file ${filename} ${cmd}
}

function fetch_cluster_worker_private_ips {
  local cluster_name=$1
  local filename=${PEG_ROOT}/tmp/${cluster_name}/hostnames
  local cmd='tail -n +2 ${filename} | tr - . | cut -b 4-'
  run_cmd_on_file ${filename} ${cmd}
}

function fetch_cluster_master_hostname {
  local cluster_name=$1
  local filename=${PEG_ROOT}/tmp/${cluster_name}/hostnames
  local cmd='head -n 1 ${filename}'
  run_cmd_on_file ${filename} ${cmd}
}

function fetch_cluster_worker_hostnames {
  local cluster_name=$1
  local filename=${PEG_ROOT}/tmp/${cluster_name}/hostnames
  local cmd='tail -n +2 ${filename}'
  run_cmd_on_file ${filename} ${cmd}
}

function fetch_cluster_hostnames {
  local cluster_name=$1
  local filename=${PEG_ROOT}/tmp/${cluster_name}/hostnames
  local cmd='cat ${filename}'
  run_cmd_on_file ${filename} ${cmd}
}

function fetch_cluster_private_ips {
  local cluster_name=$1
  local filename=${PEG_ROOT}/tmp/${cluster_name}/hostnames
  local cmd='cat ${filename} | tr - . | cut -b 4-'
  run_cmd_on_file ${filename} ${cmd}
}

function fetch_cluster_public_dns {
  local cluster_name=$1
  local filename=${PEG_ROOT}/tmp/${cluster_name}/public_dns
  local cmd='cat ${filename}'
  run_cmd_on_file ${filename} ${cmd}
}

function fetch_cluster_roles {
  local cluster_name=$1
  local filename=${PEG_ROOT}/tmp/${cluster_name}/roles
  local cmd='cat ${filename}'
  run_cmd_on_file ${filename} ${cmd}
}

function fetch_cluster_num_masters {
  local cluster_name=$1
  local filename=${PEG_ROOT}/tmp/${cluster_name}/roles
  local cmd='cat ${filename} | grep master | wc -l'
  run_cmd_on_file ${filename} ${cmd}
}

function fetch_cluster_num_workers {
  local cluster_name=$1
  local filename=${PEG_ROOT}/tmp/${cluster_name}/roles
  local cmd='cat ${filename} | grep worker | wc -l'
  run_cmd_on_file ${filename} ${cmd}
}

function port_forward {
  local cluster_name=$1
  local cluster_num=$2
  local port_cmd=$3

  local ports=($(echo ${port_cmd} | tr ":" "\n"))
  if [ "${#ports[@]}" != "2" ]; then
    echo "Specify port command as <local-port>:<remote-port>"
    exit 1
  fi

  local local_port=${ports[0]}
  local remote_port=${ports[1]}

  if [ -z ${local_port} ]; then
    echo "specify local port"
    exit 1
  fi

  if [ -z ${remote_port} ]; then
    echo "specify remote port"
    exit 1
  fi

  local pid=$(lsof -i 4:${local_port} | awk '{print $2}' | sed 1d)

  if [ ! -z ${pid} ]; then
    kill ${pid}
  fi

  local dns=$(fetch_public_dns_of_node_in_cluster ${cluster_name} ${cluster_num})

  ssh -N -f -L localhost:${local_port}:localhost:${remote_port} ${REM_USER}@${dns}
}
