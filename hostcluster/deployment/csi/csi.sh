#!/bin/bash

# echo colour
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
YELLOW=$(tput setaf 3)
CYAN=$(tput setaf 6)
BLUE=$(tput setaf 4)
NC=$(tput sgr0)

echo "${GREEN}=========================="
echo "${GREEN}Installing EBS CSI Driver"
echo "${GREEN}=========================="

if [ -z $CLUSTER_NAME ] || [ -z $AWS_REGION ] || [ -z $ACCOUNT_ID ]; then
  echo "${RED}Set environment variables CLUSTER_NAME, AWS_REGION, and ACCOUNT_ID before installing EBS CSI Driver"
  exit 1
else 
  
  
# Create trust policy for EBS CSI Driver Role
  cat << EOF > trust-policy.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "pods.eks.amazonaws.com"
            },
            "Action": [
                "sts:AssumeRole",
                "sts:TagSession"
            ]
        }
    ]
}
EOF

  echo "${YELLOW}Creating IAM role for EBS CSI Driver"
  aws iam create-role --role-name AmazonEKS_EBS_CSI_DriverRole --assume-role-policy-document file://trust-policy.json

  echo "${YELLOW}Attaching EBS CSI Driver policy to the role"
  aws iam attach-role-policy --role-name AmazonEKS_EBS_CSI_DriverRole --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy


  echo "${YELLOW}Creating service account for EBS CSI Driver"
  kubectl create sa ebs-csi-controller-sa -n kube-system

  echo "${YELLOW}Installing EBS CSI Driver addon"
  aws eks create-addon --cluster-name $CLUSTER_NAME --addon-name aws-ebs-csi-driver \
    --pod-identity-associations serviceAccount=ebs-csi-controller-sa,roleArn=arn:aws:iam::${ACCOUNT_ID}:role/AmazonEKS_EBS_CSI_DriverRole

  # Clean up
  rm trust-policy.json

  echo "${GREEN}=========================="
  echo "${GREEN}EBS CSI Driver installation completed"
  echo "${GREEN}=========================="
fi