#!/usr/bin/env bats

source ${PEG_ROOT}/util.sh

setup() {
  mkdir ${PEG_ROOT}/test/tmp
}

teardown() {
  rm -rf ${PEG_ROOT}/test/tmp
}

@test "parse templates valid on-demand" {
  eval $(parse_yaml ${PEG_ROOT}/test/templates/valid_ondemand.yml)

  [ "$purchase_type" = "on_demand" ]
  [ "$subnet_id" = "subnet-3a78835f" ]
  [ "$num_instances" = "1" ]
  [ "$key_name" = "insight-cluster" ]
  [ "$security_group_ids" = "sg-9206aaf7" ]
  [ "$instance_type" = "m4.large" ]
  [ "$tag_name" = "test-cluster" ]
  [ "$vol_size" = "100" ]
  [ "$role" = "master" ]
  [ "$use_eips" = "true" ]
}

@test "parse templates valid spot" {
  eval $(parse_yaml ${PEG_ROOT}/test/templates/valid_spot.yml)

  [ "$purchase_type" = "spot" ]
  [ "$price" = "0.25" ]
  [ "$subnet_id" = "subnet-3a78835f" ]
  [ "$num_instances" = "1" ]
  [ "$key_name" = "insight-cluster" ]
  [ "$security_group_ids" = "sg-9206aaf7" ]
  [ "$instance_type" = "m4.large" ]
  [ "$tag_name" = "test-cluster" ]
  [ "$vol_size" = "100" ]
  [ "$role" = "master" ]
  [ "$use_eips" = "true" ]
}

@test "parse templates valid with whitespaces and newlines" {
  eval $(parse_yaml ${PEG_ROOT}/test/templates/valid_ws.yml)
  [ "$purchase_type" = "on_demand" ]
  [ "$subnet_id" = "subnet-3a78835f" ]
  [ "$num_instances" = "1" ]
  [ "$key_name" = "insight-cluster" ]
  [ "$security_group_ids" = "sg-9206aaf7" ]
  [ "$instance_type" = "m4.large" ]
  [ "$tag_name" = "test-cluster" ]
  [ "$vol_size" = "100" ]
  [ "$role" = "master" ]
  [ "$use_eips" = "true" ]
}
