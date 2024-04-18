#!/bin/bash
echo "Setting environment variables"

export AWS_REGION="us-east-2"
export ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"

#Cluster Variables
export CLUSTER_NAME="vcluster-demo-3"
export K8sversion="1.29"


# echo colour
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
CYAN=$(tput setaf 6)
BLUE=$(tput setaf 4)
NC=$(tput sgr0)