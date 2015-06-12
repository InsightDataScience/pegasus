#!/bin/bash
NODE=$1

ssh -i $PEMLOC ubuntu@$(sed -n ''"$NODE"'p' public_dns)
