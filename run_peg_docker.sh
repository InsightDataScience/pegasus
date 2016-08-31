#!/bin/bash

# Copyright 2015 Insight Data Science
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

tag=0.1.3

nargs="$#"

if [ "${nargs}" -ne 2 ]; then
  echo "incorrect number of arguments"
  echo "./run_peg_docker.sh <pem-key-name> <instance-template-folder>"
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
  -e AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID:?"set AWS_ACCESS_KEY_ID before proceeding"} \
  -e AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY:?"set AWS_SECRET_ACCESS_KEY before proceeding"} \
  -e AWS_DEFAULT_REGION=${AWS_DEFAULT_REGION:?"set AWS_DEFAULT_REGION before proceeding"} \
  -e USER=${USER:=pegasus} \
  -v ~/.ssh/${pem_key_name}.pem:/root/.ssh/${pem_key_name}.pem \
  -v ${instance_template_folder}:/root/${folder_name} \
  insightdatascience/pegasus:${tag}
