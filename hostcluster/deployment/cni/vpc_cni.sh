#!/bin/bash
#*************************
# Deploy VPC CNI addon
#*************************

source ./hostcluster/environmentVariables.sh

echo "${GREEN}=========================="
echo "${GREEN}Installing VPC CNI N/W Policy"
echo "${GREEN}=========================="

if [ -z $CLUSTER_NAME ] || [ -z $AWS_REGION ] || [ -z $ACCOUNT_ID ] ;then
echo "${RED}Update values & Run environmentVariables.sh file"
exit 1;
else 

oidc_id=$(aws eks describe-cluster --name $cluster_name --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)
echo $oidc_id

openId_connect=$(aws iam list-open-id-connect-providers | grep $oidc_id | cut -d "/" -f4)

if $openId_connect; then
    echo "Provider already exists"
    echo $openId_connect
else
    eksctl utils associate-iam-oidc-provider --cluster $cluster_name --approve
fi


aws eks describe-cluster --name $cluster_name | grep ipFamily


eksctl create iamserviceaccount \
    --name aws-node \
    --namespace kube-system \
    --cluster $cluster_name \
    --role-name AmazonEKSVPCCNIRole \
    --attach-policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy \
    --override-existing-serviceaccounts \
    --approve

addon_name="vpc-cni"

# Attempt to describe the addon and capture the output
output=$(aws eks describe-addon --cluster-name "$cluster_name" --addon-name "$addon_name" --query addon.addonVersion --output text 2>&1)

if echo "$output" | grep -q "ResourceNotFoundException"; then
  echo "Addon $addon_name not found in cluster $cluster_name."
  aws eks create-addon --cluster-name $cluster_name --addon-name vpc-cni --addon-version v1.18.1-eksbuild.3 \
    --service-account-role-arn arn:aws:iam::809980971988:role/AmazonEKSVPCCNIRole \
    --resolve-conflicts PRESERVE --configuration-values '{"enableNetworkPolicy": "true"}'
else
  echo "Addon version: $output"
fi
#Confirm that the aws-node pods are running on your cluster.

kubectl get pods -n kube-system | grep 'aws-node\|amazon'

echo "${GREEN}==========================" 
echo "${GREEN}VPC CNI installation completed"
echo "${GREEN}=========================="

fi
                        