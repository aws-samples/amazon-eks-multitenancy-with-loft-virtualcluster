#!/bin/bash
#*************************
# Deploy VPC CNI addon
#*************************

# source ./hostcluster/environmentVariables.sh

# echo colour
RED=$(tput setaf 1)
GREEN=$(tput setaf 2)
CYAN=$(tput setaf 6)
BLUE=$(tput setaf 4)
NC=$(tput sgr0)

echo "${GREEN}=========================="
echo "${GREEN}Installing VPC CNI N/W Policy"
echo "${GREEN}=========================="

if [ -z $CLUSTER_NAME ] || [ -z $AWS_REGION ] || [ -z $ACCOUNT_ID ] ;then
  # echo "${RED}Update values & Run environmentVariables.sh file"
  echo "Set environment variable before installing CNI"
  exit 1;
else 

#==========================
#==========IRSA============
#==========================

    #   oidc_id=$(aws eks describe-cluster --name "$CLUSTER_NAME" --region "$AWS_REGION" --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)
    #   echo "${YELLOW}oidc_id:${oidc_id}"
    #   openId_connect_providers=$(aws iam list-open-id-connect-providers --output text | grep "$oidc_id" | cut -d "/" -f4)
    #   echo "${YELLOW}openId_connect_providers:${openId_connect_providers}"


    #   if [[ "$openId_connect_providers" == "" ]]; then
    #     echo "OIDC ID is missing, install now"
    #     eksctl utils associate-iam-oidc-provider --cluster "$CLUSTER_NAME" --approve
    #     oidc_id=$(aws eks describe-cluster --name "$CLUSTER_NAME" --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)

    #     openId_connect_providers=$(aws iam list-open-id-connect-providers | grep "$oidc_id" | cut -d "/" -f4)
    #     echo "${YELLOW}openId_connect_providers:${openId_connect_providers}"
    #   else
    #     echo "${GREEN}OIDC ID providers available: $openId_connect_providers"
    #   fi

    #   echo "${GREEN}*************OIDC setup completed*************"

    # if aws iam get-role --role-name "$VPC_CNI_ROLE$CLUSTER_NAME" >/dev/null 2>&1; then
    #     echo "Role exists."
    # else
      
    # echo "Role does not exist."

    #     #Create Policy
    #   OIDC_PROVIDER=$(aws eks describe-cluster --name ${CLUSTER_NAME} --region ${AWS_REGION} --query "cluster.identity.oidc.issuer" --output text | sed -e "s/^https:\/\///")
    #   echo "${YELLOW}OIDC_PROVIDER: $OIDC_PROVIDER"
    # policy=$(cat <<EOF
    # {
    #     "Version": "2012-10-17",
    #     "Statement": [
    #         {
    #             "Effect": "Allow",
    #             "Principal": {
    #                 "Federated": "arn:aws:iam::$ACCOUNT_ID:oidc-provider/oidc.eks.$AWS_REGION.amazonaws.com/id/${oidc_id}"
    #             },
    #             "Action": "sts:AssumeRoleWithWebIdentity",
    #             "Condition": {
    #                 "StringEquals": {
    #                     "${OIDC_PROVIDER}:aud": "sts.amazonaws.com",
    #                     "${OIDC_PROVIDER}:sub": "system:serviceaccount:kube-system:aws-node"
    #                 }
    #             }
    #         }
    #     ]
    # }
    # EOF
    # )
    #   echo "${YELLOW}Policy : "$policy
    #   #Create the role
    #   create_role=$(aws iam create-role  --role-name "$VPC_CNI_ROLE$CLUSTER_NAME" --assume-role-policy-document "$policy")
    #   echo "${GREEN} Role created: "$create_role

    #   check_role_exists() {
    #     aws iam get-role --role-name "$VPC_CNI_ROLE$CLUSTER_NAME" >/dev/null 2>&1
    #   }

    #     echo "${YELLOW}Waiting for role to be created..."
    #     while ! check_role_exists; do
    #       sleep 5
    #       echo "${RED}Still waiting..."
    #     done

    #     #Attach the required IAM policy
    #     aws iam attach-role-policy \
    #       --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy \
    #       --role-name $VPC_CNI_ROLE$CLUSTER_NAME
    #     echo "${GREEN}Policy attached to role"
    # fi



      

    #     echo "${GREEN}*************Role and Policy setup completed*************"



    #     describe_addon() {
    #       aws eks describe-addon --cluster-name "$CLUSTER_NAME" --addon-name vpc-cni 2>&1
    #     }

    #     # Run the command and capture the output and exit status
    #     output=$(describe_addon)
    #     echo $?
    #     exit_status=$?

    #     role_arn=arn:aws:iam::"$ACCOUNT_ID":role/"$VPC_CNI_ROLE$CLUSTER_NAME"
    #     echo $role_arn

    #   # if [ $exit_status -ne 0 ]; then
    #     # Check if the error is a ResourceNotFoundException
    #     if echo "$output" | grep -q "ResourceNotFoundException"; then
    #       echo "${RED}Addon not found: vpc-cni"
    #       echo "${YELLOW}Start creating Addon : vpc-cni"
          
    #       create_addon=$(aws eks create-addon --cluster-name "$CLUSTER_NAME" --addon-name vpc-cni --addon-version "$VPC_CNI_VERSION" \
    #       --service-account-role-arn  $role_arn \
    #       --resolve-conflicts PRESERVE --configuration-values '{"enableNetworkPolicy": "true"}')
        
    #     echo "${GREEN}Complete Addon : vpc-cni"
    #     else
    #       echo "${RED} Update Addon: $output"
    #       VPC_CNI_VERSION=v1.18.2-eksbuild.1
    #       update_addon=$(aws eks update-addon --cluster-name "$CLUSTER_NAME" --addon-name vpc-cni --addon-version "$VPC_CNI_VERSION" \
    #       --service-account-role-arn $role_arn \
    #       --resolve-conflicts PRESERVE --configuration-values '{"enableNetworkPolicy": "true"}')
    #       echo "${GREEN}Updated Addon : vpc-cni"
    #     fi
    #   # else
    #   #   echo "${GREEN}Addon details:"
    #   #   echo "${GREEN}$output" | jq
    #   # fi

    #   echo "${GREEN}*************Addon setup completed*************"
    #   kubectl get pods -n kube-system | grep 'aws-node|amazon'
    # fi





# ====================
# Using PodIdentity
# ====================
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

  echo "${YELLOW}Create role & assign role policy"
  create_role=$(aws iam create-role --role-name AmazonEKS_VPC_CNI_DriverRole --assume-role-policy-document file://trust-policy.json)
  echo "${YELLOW} Assign CNI policy to role"
  aws iam attach-role-policy --role-name AmazonEKS_VPC_CNI_DriverRole --policy-arn arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy

  echo "${YELLOW}Create PodIdentity addon"
  create_podIdentity=$(aws eks create-addon --cluster-name $CLUSTER_NAME --region $AWS_REGION  --addon-name eks-pod-identity-agent --addon-version v1.2.0-eksbuild.1)

  echo "${YELLOW}Create service account in kube-system namespace"
  kubectl create sa aws-node -n kube-system

  describe_addon() {
      aws eks describe-addon --cluster-name "$CLUSTER_NAME" --addon-name vpc-cni 2>&1
    }

    # Run the command and capture the output and exit status
    output=$(describe_addon)
    echo $?
    exit_status=$?

    role_arn=arn:aws:iam::"$ACCOUNT_ID":role/"$VPC_CNI_ROLE$CLUSTER_NAME"
    echo $role_arn

    if echo "$output" | grep -q "ResourceNotFoundException"; then
      echo "${RED}Addon not found: vpc-cni"
      echo "${YELLOW}Start creating Addon : vpc-cni"

      create_cni=$(aws eks create-addon --cluster-name $CLUSTER_NAME --addon-name vpc-cni --addon-version "$VPC_CNI_VERSION" \
        --pod-identity-associations serviceAccount=aws-node,roleArn=arn:aws:iam::"$ACCOUNT_ID":role/AmazonEKS_VPC_CNI_DriverRole \
        --resolve-conflicts PRESERVE --configuration-values '{"enableNetworkPolicy": "true"}')
      
      echo "${GREEN}Created Addon : vpc-cni"
    else
      echo "${RED} Update Addon: $output"
      VPC_CNI_VERSION=v1.18.2-eksbuild.1
      update_addon=$(aws eks update-addon --cluster-name "$CLUSTER_NAME" --addon-name vpc-cni --addon-version "$VPC_CNI_VERSION" \
      --pod-identity-associations serviceAccount=aws-node,roleArn=arn:aws:iam::"$ACCOUNT_ID":role/AmazonEKS_VPC_CNI_DriverRole \
      --resolve-conflicts PRESERVE --configuration-values '{"enableNetworkPolicy": "true"}')
      echo "${GREEN}Updated Addon : vpc-cni"
    fi
fi

echo "${GREEN}==========================" 
echo "${GREEN}VPC CNI installation completed"
echo "${GREEN}=========================="