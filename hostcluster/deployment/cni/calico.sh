#!/bin/bash
#*************************
# Deploy Calico
#*************************
source ./hostcluster/environmentVariables.sh

if [ -z $CLUSTER_NAME ] || [ -z $AWS_REGION ] || [ -z $ACCOUNT_ID ] ;then
echo "${RED}Update values & Run environmentVariables.sh file"
exit 1;
else 

echo "${GREEN}=========================="
echo "${GREEN}Installing Calico policy manager"
echo "${GREEN}=========================="

kubectl create -f ./hostcluster/deployment/cni/tigera-operator.yaml
# kubectl delete -f ./hostcluster/deployment/cni/tigera-operator.yaml
kubectl create -f - <<EOF
  kind: Installation
  apiVersion: operator.tigera.io/v1
  metadata:
    name: default
  spec:
    kubernetesProvider: EKS
    cni:
      type: Calico
    calicoNetwork:
      bgp: Disabled
EOF

#############################################################################
###RESTART THE NOD EELSE IT FAILS TO IMPLEMENT N/W POLIC####################
#############################################################################
echo "${GREEN}==========================" 
echo "${GREEN}Calico installation completed"
echo "${GREEN}=========================="


fi