#!/bin/bash
#*************************
# Deploy CSI
#*************************
echo "${GREEN}=========================="
echo "${GREEN}Installing EBS CSI Driver"
echo "${GREEN}=========================="
source ./hostcluster/environmentVariables.sh

if [ -z $CLUSTER_NAME ] || [ -z $AWS_REGION ] || [ -z $ACCOUNT_ID ] ;then
echo "${RED}Update values & Run environmentVariables.sh file"
exit 1;
else 
echo "${GREEN}**Start CSI provisioning**"

echo "${GREEN}Create IAM policy"
csi_policy=$(aws iam create-policy \
    --policy-name Amazon_EBS_CSI_Driver_$CLUSTER_NAME \
    --policy-document file://hostcluster/deployment/csi/policy.json \
    --output text --query Policy.Arn)
echo $csi_policy

echo "${GREEN}Get Worker node IAM Role ARN"

worker_node_role=$(kubectl describe configmap aws-auth -n kube-system | grep "rolearn:" | awk -F'/' '{print $NF}')
echo $worker_node_role
aws iam attach-role-policy \
    --policy-arn ${csi_policy} \
    --role-name ${worker_node_role}

echo "${GREEN}CSI policy attached to worker node role"

echo "${GREEN}Deploy EBS CSI Driver"
kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"
# kubectl delete -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"
echo "${GREEN}Verify ebs-csi pods running"
kubectl get pods -n kube-system

fi

echo "${GREEN}==========================" 
echo "${GREEN}CSI installation completed"
echo "${GREEN}=========================="