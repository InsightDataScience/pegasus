#!/bin/bash

nargs="$#"

if [ "${nargs}" -ne 2 ]; then
  echo "incorrect number of arguments"
  echo "run.sh <pem-key-name> <instance-template-folder>"
  exit 1
fi

pem_key_name=$1
instance_template_folder=$2

if [ ! -f ~/.ssh/${pem_key_name}.pem ]; then
  echo "${pem_key_name} does not exist in your ~/.ssh folder"
  exit 1
fi

if [ ! -d ${instance_template_folder} ]; then
  echo "${instance_template_folder} directory does not exist"
  exit 1
fi

folder_split=($(echo ${instance_template_folder} | tr "/" " "))
folder_name=${folder_split[${#folder_split[@]}-1]}

docker run -it --rm --name peg \
  -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:?"set AWS_ACCESS_KEY_ID"} \
  -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:?"set AWS_SECRET_ACCESS_KEY"} \
  -e USER=${USER:=pegasus} \
  -v ~/.ssh/${pem_key_name}.pem:/root/.ssh/${pem_key_name}.pem \
  -v ${instance_template_folder}:/root/${folder_name} \
  insightdatascience/pegasus:0.1.0
