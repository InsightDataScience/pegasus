#!/bin/bash
CLUSTER_NAME=$1
NODE=$2

ssh -i $PEMLOC ubuntu@$(sed -n ''"$NODE"'p' tmp/$CLUSTER_NAME/public_dns)
