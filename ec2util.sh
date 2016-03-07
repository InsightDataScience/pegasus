#!/bin/bash

PEG_ROOT=$(dirname "${BASH_SOURCE}")

function get_public_dns_with_name {
  local cluster_name=$1
  aws ec2 describe-instances \
    --region ${REGION:=us-west-2} \
    --output text \
    --filters Name=tag:Name,Values=${cluster_name} \
    --query Reservations[].Instances[].NetworkInterfaces[].Association.PublicDnsName
}

function get_private_dns_with_name {
  local cluster_name=$1
  aws ec2 describe-instances \
    --region ${REGION:=us-west-2} \
    --output text \
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
  aws ec2 describe-instances \
    --region ${REGION:=us-west-2} \
    --output text \
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
  aws ec2 describe-instances \
    --region ${REGION:=us-west-2} \
    --output text \
    --filters Name=tag:Name,Values=${cluster_name} \
    --query Reservations[].Instances[].Tags[?key=='Name'].Value
}

function get_instance_types_with_name {
  local cluster_name=$1
  aws ec2 describe-instances \
    --region ${REGION:=us-west-2} \
    --output text \
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
