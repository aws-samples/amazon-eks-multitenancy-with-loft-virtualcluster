## Amazon Eks Multitenancy with Loft vCluster
<p>
<img src="https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white" />
<img src="https://img.shields.io/badge/python%20-%2314354C.svg?&style=for-the-badge&logo=python&logoColor=white"/>
<img src="https://img.shields.io/badge/AWS%20-%23FF9900.svg?&style=for-the-badge&logo=amazon-aws&logoColor=white"/> 
<img src="https://img.shields.io/badge/docker%20-%230db7ed.svg?&style=for-the-badge&logo=docker&logoColor=white"/>
<img src="https://img.shields.io/badge/AWS-EKS-orange"/>


</p>

## What is Loft vCluster?
vCluster is a Kubernetes-native solution that allows you to create fully functional virtual Kubernetes clusters inside regular Kubernetes namespaces. Each virtual cluster has its own API server, control plane, and data store, providing strong isolation and multi-tenancy on top of a shared underlying Kubernetes cluster.
*** 
## Reference Architecture
<p align="center">
  <img  src="https://github.com/khanasif1/aws-eks-loft-vcluster/blob/main/architetcure/HL_RefArchitecture.svg">
</p>

*** 
# Deploy Solution

## Deploy cluster with CSI, CNI components

* Navigate to path

```
cd <path>/aws-eks-loft-vcluster/hostcluster/

```
* Edit environmentVariables.sh with relevent values

```
export AWS_REGION="us-east-2"  # edit as needed
export ACCOUNT_ID="$(aws sts get-caller-identity --query Account --output text)"

#Cluster Variables
export CLUSTER_NAME="vcluster-demo" # edit as needed
export KUBERNETES_VERSION="1.28" # edit as needed

export VPC_CNI_ROLE="AmazonEKSVPCCNIRole" # edit as needed
export VPC_CNI_VERSION="v1.18.2-eksbuild.1" # edit as needed

```

* Run scritp _main.sh

```
sh ./hostcluster/_main.sh 

```