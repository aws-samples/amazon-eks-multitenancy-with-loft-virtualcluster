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

oidc_id=$(aws eks describe-cluster --name "$cluster_name" --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)
echo $oidc_id

if [ "$oidc_id" = "None" ]; then
  echo "OIDC ID is missing, install now"
  eksctl utils associate-iam-oidc-provider --cluster "$CLUSTER_NAME" --approve
  oidc_id=$(aws eks describe-cluster --name "$CLUSTER_NAME" --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)
  echo $oidc_id
  openId_connect=$(aws iam list-open-id-connect-providers | grep "$oidc_id" | cut -d "/" -f4)
else
  echo "OIDC ID: $oidc_id"
fi


#Create Policy
OIDC_PROVIDER=$(aws eks describe-cluster --name ${CLUSTER_NAME} --region ${AWS_REGION} --query "cluster.identity.oidc.issuer" --output text | sed -e "s/^https:\/\///")
policy=$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::$ACCOUNT_ID:oidc-provider/oidc.eks.$AWS_REGION.amazonaws.com/id/$oidc_id"
            },
            "Action": "sts:AssumeRoleWithWebIdentity",
            "Condition": {
                "StringEquals": {
                    "${OIDC_PROVIDER}:aud": "sts.amazonaws.com",
                    "${OIDC_PROVIDER}:sub": "system:serviceaccount:kube-system:aws-node"
                }
            }
        }
    ]
}
EOF
)
#Create the role
aws iam create-role \
  --role-name AmazonEKSVPCCNIRole \
  --assume-role-policy-document $policy

#Attach the required IAM policy
aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy \
  --role-name AmazonEKSVPCCNIRole

#Run the following command to annotate the K8s aws-node service account with the ARN of the IAM role that you created previously.
# kubectl annotate serviceaccount \
#     -n kube-system aws-node \
#     eks.amazonaws.com/role-arn=arn:aws:iam::$ACCOUNT_ID:role/AmazonEKSVPCCNIRole


aws eks describe-cluster --name "$CLUSTER_NAME" | grep ipFamily


# eksctl create iamserviceaccount \
#     --name aws-node \
#     --namespace kube-system \
#     --cluster "$CLUSTER_NAME" \
#     --role-name AmazonEKSVPCCNIRole \
#     --attach-policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy \
#     --override-existing-serviceaccounts \
#     --approve

addon_name="vpc-cni"

# Attempt to describe the addon and capture the output
output=$(aws eks describe-addon --cluster-name "$CLUSTER_NAME" --addon-name "$addon_name" --query addon.addonVersion --output text 2>&1)

if echo "$output" | grep -q "ResourceNotFoundException"; then
  echo "Addon $addon_name not found in cluster $CLUSTER_NAME."
  aws eks create-addon --cluster-name "$CLUSTER_NAME" --addon-name vpc-cni --addon-version v1.18.1-eksbuild.3 \
    --service-account-role-arn arn:aws:iam::"$ACCOUNT_ID":role/AmazonEKSVPCCNIRole \
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
                        