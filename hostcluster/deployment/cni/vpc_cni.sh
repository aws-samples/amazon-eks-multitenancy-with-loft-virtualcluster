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

oidc_id=$(aws eks describe-cluster --name "$CLUSTER_NAME" --region "$AWS_REGION" --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)
echo "oidc_id:${oidc_id}"
openId_connect_providers=$(aws iam list-open-id-connect-providers --output text | grep "$oidc_id" | cut -d "/" -f4)
echo "openId_connect_providers:${openId_connect_providers}"


if [[ "$openId_connect_providers" == "" ]]; then
  echo "OIDC ID is missing, install now"
  eksctl utils associate-iam-oidc-provider --cluster "$CLUSTER_NAME" --approve
  oidc_id=$(aws eks describe-cluster --name "$CLUSTER_NAME" --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)
  echo $oidc_id
  openId_connect_providers=$(aws iam list-open-id-connect-providers | grep "$oidc_id" | cut -d "/" -f4)
  echo "openId_connect_providers:${openId_connect_providers}"
else
  echo "OIDC ID providers: $openId_connect_providers"
fi


#Create Policy
OIDC_PROVIDER=$(aws eks describe-cluster --name ${CLUSTER_NAME} --region ${AWS_REGION} --query "cluster.identity.oidc.issuer" --output text | sed -e "s/^https:\/\///")
echo "OIDC_PROVIDER: $OIDC_PROVIDER"
policy=$(cat <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Principal": {
                "Federated": "arn:aws:iam::$ACCOUNT_ID:oidc-provider/oidc.eks.$AWS_REGION.amazonaws.com/id/${oidc_id}"
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
echo "Policy : "$policy
#Create the role
create_role=$(aws iam create-role  --role-name "$VPC_CNI_ROLE" --assume-role-policy-document "$policy")
echo "Create role: "$create_role

check_role_exists() {
  aws iam get-role --role-name "$VPC_CNI_ROLE" >/dev/null 2>&1
}

echo "Waiting for role to be created..."
while ! check_role_exists; do
  sleep 5
  echo "Still waiting..."
done

#Attach the required IAM policy
aws iam attach-role-policy \
  --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy \
  --role-name $VPC_CNI_ROLE
 echo "Policy attached to role"

describe_addon() {
  aws eks describe-addon --cluster-name "$CLUSTER_NAME" --addon-name vpc-cni 2>&1
}

# Run the command and capture the output and exit status
output=$(describe_addon)
exit_status=$?


if [ $exit_status -ne 0 ]; then
  # Check if the error is a ResourceNotFoundException
  if echo "$output" | grep -q "ResourceNotFoundException"; then
    echo "Addon not found: vpc-cni"
    echo "Start creating Addon : vpc-cni"
     create_addon=$(aws eks create-addon --cluster-name "$CLUSTER_NAME" --addon-name vpc-cni --addon-version "$VPC_CNI_VERSION" \
    --service-account-role-arn arn:aws:iam::"$ACCOUNT_ID":role/"$VPC_CNI_ROLE" \
    --resolve-conflicts PRESERVE --configuration-values '{"enableNetworkPolicy": "true"}')
  else
    echo "An error occurred: $output"
  fi
else
  echo "Addon details:"
  echo "$output" | jq
fi


kubectl get pods -n kube-system | grep 'aws-node\|amazon'

echo "${GREEN}==========================" 
echo "${GREEN}VPC CNI installation completed"
echo "${GREEN}=========================="

fi
                        