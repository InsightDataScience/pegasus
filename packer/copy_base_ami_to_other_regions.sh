#!/bin/bash

SOURCE_REGION=us-west-2
BASE_AMI_ID=ami-62e01e02
DEST_REGIONS=(
    us-east-1
    )

function copy_ami {
    local source_region=$1
    local dest_region=$2
    local base_ami_id=$3

    aws ec2 copy-image \
        --source-region $source_region \
        --source-image-id $base_ami_id \
        --name pegasus-ubuntu16-java8-$(date +%s) \
        --region $dest_region \
        --output text
}

function make_ami_public {
    local base_ami_id=$1

    aws ec2 modify-image-attribute \
        --image-id "$base_ami_id" \
        --launch-permission "{\"Add\": [{\"Group\":\"all\"}]}"
}

for DEST_REGION in ${DEST_REGIONS[@]}; do
    OUTPUT_AMI_ID=$(copy_ami ${SOURCE_REGION} ${DEST_REGION} ${BASE_AMI_ID})
    make_ami_public ${OUTPUT_AMI_ID}
    cat "${DEST_REGION}: ${OUTPUT_AMI_ID}" >> region_ami_mapping.yaml
    sleep 3
done

