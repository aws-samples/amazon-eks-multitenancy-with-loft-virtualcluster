
#!/bin/bash
#*************************
# Create a Cluster with Karpenter
#************************* 

echo "${GREEN}=========================="
echo "${GREEN}Start Cleanup"
echo "${GREEN}=========================="

echo "${GREEN}Load environment variables"
source ./hostcluster/environmentVariables.sh

echo "${RED}Delete EKS cluster"

eksctl delete cluster --name ${CLUSTER_NAME} --region ${AWS_REGION}

echo "${RED}Cluter deleted"

echo "${RED}Delete Policy for CSI"

policy_name='Amazon_EBS_CSI_Driver_'${CLUSTER_NAME}
policy=$(aws iam list-policies --query "Policies[?starts_with(PolicyName,'$policy_name')].[Arn]" --output text)

echo "${RED}Get policy ARN"
echo "Policy ARN : $policy"

aws iam delete-policy --policy-arn $policy

echo "${RED}Policy deleted"


