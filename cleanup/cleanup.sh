
#!/bin/bash
#*************************
# Create a Cluster with Karpenter
#************************* 

echo "${GREEN}=========================="
echo "${GREEN}Start Cleanup"
echo "${GREEN}=========================="

echo "${GREEN}Load environment variables"
source ./hostcluster/environmentVariables.sh

echo "${RED}*********Delete EKS cluster*********"

eksctl delete cluster --name ${CLUSTER_NAME} --region ${AWS_REGION}

echo "${RED}Cluter deleted"

echo "${RED}*********Delete Policy for CSI*********"

policy_name='Amazon_EBS_CSI_Driver_'${CLUSTER_NAME}
policy=$(aws iam list-policies --query "Policies[?starts_with(PolicyName,'$policy_name')].[Arn]" --output text)

echo "${RED}Get policy ARN"
echo "Policy ARN : $policy"

aws iam delete-policy --policy-arn $policy

echo "${RED}Policy deleted"

echo "${RED}*********Delete Policy for CNI*********"
policy_arn="arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"

# Detach the policy from the IAM role
aws iam detach-role-policy --role-name $VPC_CNI_ROLE$CLUSTER_NAME --policy-arn $policy_arn

# Delete the IAM role
aws iam delete-role --role-name $VPC_CNI_ROLE$CLUSTER_NAME


# VPC CNI Cleanup

    #     # List OIDC providers and find the correct one
    #     oidc_provider_url=$(aws eks describe-cluster --name "$CLUSTER_NAME" --region "$AWS_REGION" --query "cluster.identity.oidc.issuer" --output text)
    #     echo $oidc_provider_url
    #     # Extract the OIDC provider ARN
    #     oidc_provider_arn=$(aws iam list-open-id-connect-providers --query 'OpenIDConnectProviderList[*].Arn' --output json | grep ${oidc_provider_url#https://})
    #     echo $oidc_provider_arn

    #     oidc_provider_arn=${oidc_provider_arn//\",/}
    #     oidc_provider_arn=${oidc_provider_arn//\"/}
    #     oidc_provider_arn=$(echo "$oidc_provider_arn" | tr -cd '[:alnum:]_./:=+-@')
    #     echo $oidc_provider_arn
    #     # Remove the IAM OIDC provider
    #     if [ -n "$oidc_provider_arn" ]; then
    #     aws iam delete-open-id-connect-provider --open-id-connect-provider-arn "$oidc_provider_arn"
    #     echo "OIDC provider $oidc_provider_arn removed successfully."
    #     else
    #     echo "OIDC provider for cluster $CLUSTER_NAME not found."
    #     fi


    # # Set your variables
    #     role_name="AmazonEKSVPCCNIRolevcluster-demo-4"
    #     policy_arn="arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    #     service_account_name="aws-node"
    #     namespace="kube-system"
    #     addon_name="vpc-cni"

    #     # Detach the policy from the IAM role
    #     aws iam detach-role-policy --role-name $role_name --policy-arn $policy_arn

    #     # Delete the IAM role
    #     aws iam delete-role --role-name $role_name

    #     # # Delete the Kubernetes service account
    #     # delete_svc_acc=$(kubectl delete serviceaccount $service_account_name -n $namespace)

    #     # echo "Service account and IAM role deleted successfully."

    #     # Delete the EKS addon
    #     aws eks delete-addon --cluster-name $CLUSTER_NAME --addon-name $addon_name

    #     echo "Addon, IAM role, and policy deleted successfully."

echo "${GREEN}=========================="
echo "${GREEN}End Cleanup"
echo "${GREEN}=========================="