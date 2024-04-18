#!/bin/bash
#*************************
# Create a Cluster with Karpenter
#************************* 

echo "${GREEN}=========================="
echo "${GREEN}Installing Cluster"
echo "${GREEN}=========================="
source ./hostcluster/environmentVariables.sh

if [ -z $CLUSTER_NAME ] || [ -z $AWS_REGION ] || [ -z $ACCOUNT_ID ] ;then
echo "${RED}Update values & Run environmentVariables.sh file"
exit 1;
else 
echo "${GREEN}**Start cluster provisioning**"

CHECK_CLUSTER=$(aws eks list-clusters --region ${AWS_REGION} | jq -r ".clusters" | grep $CLUSTER_NAME || true)
if [ ! -z $CHECK_CLUSTER ];then
echo "${BLUE}Cluster Exists"
else
echo "${YELLOW}Cluster does not exists"
echo "${GREEN} !!Create a eks cluster !!"

eksctl create cluster --name ${CLUSTER_NAME} --region ${AWS_REGION} --version ${K8sversion} 

fi
echo "${GREEN}==========================" 
echo "${GREEN}Cluster Completed"
echo "${GREEN}=========================="
fi