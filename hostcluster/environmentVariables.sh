#!/bin/bash
echo "Setting environment variables"

export AWS_REGION="us-east-2"
export ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"

#Cluster Variables
export CLUSTER_NAME="vcluster-demo-4"
export KUBERNETES_VERSION="1.30"

export VPC_CNI_ROLE="AmazonEKSVPCCNIRole"
export VPC_CNI_VERSION="v1.18.2-eksbuild.1"
# echo colour
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
CYAN=$(tput setaf 6)
BLUE=$(tput setaf 4)
NC=$(tput sgr0)