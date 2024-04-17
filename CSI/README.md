# Install CSI driver for EBS
 - Create IAM Policy for EBS
 - Associate IAM Policy to Worker Node IAM Role
 - Install EBS CSI Driver

## Create policy

https://www.stacksimplify.com/aws-eks/kubernetes-storage/install-aws-ebs-csi-driver-on-aws-eks-for-persistent-storage/

- Name: Amazon_EBS_CSI_Driver
- Description: Policy for EC2 Instances to access Elastic Block Store
- Click on Create Policy


## Get the role associated to Worker Node
 ```shell

kubectl -n kube-system describe configmap aws-auth

```

## Deploy Amazon EBS CSI Driver
Verify kubectl version, it should be 1.14 or later

```shell
kubectl version --client --short

```

- Deploy EBS CSI Driver

```shell

kubectl apply -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"
# kubectl delete -k "github.com/kubernetes-sigs/aws-ebs-csi-driver/deploy/kubernetes/overlays/stable/?ref=master"

# Verify ebs-csi pods running
kubectl get pods -n kube-system

```

