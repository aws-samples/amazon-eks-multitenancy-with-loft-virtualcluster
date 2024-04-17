cluster_name=vcluster-demo-1 

# Add Policy
AmazonEKS_CNI_Policy --> #to EKS Role attached to "{EC2}"

# Check IPV4 or IPv6
  
aws eks describe-cluster --name $cluster_name --region ap-southeast-2 | grep ipFamily

#See which version of the add-on is installed on your cluster
kubectl describe daemonset aws-node --namespace kube-system | grep amazon-k8s-cni: | cut -d : -f 3

# See which type of the add-on is installed on your cluster
aws eks describe-addon --cluster-name $cluster_name --region ap-southeast-2 --addon-name vpc-cni --query addon.addonVersion --output text
##If a version number is returned, you have the Amazon EKS type of the add-on installed on your cluster and don't need to complete the remaining steps in this procedure.

# Create Add-On

aws eks create-addon --cluster-name $cluster_name --addon-name vpc-cni --region ap-southeast-2 --addon-version v1.18.0-eksbuild.1 

# Confirm that the latest version of the add-on for your cluster's Kubernetes version was added to your cluster

eksctl get addon --cluster $cluster_name --region ap-southeast-2

eksctl get addon --name vpc-cni --cluster $cluster_name --region ap-southeast-2

#eksctl delete addon --cluster $cluster_name --region ap-southeast-2 --name vpc-cni



