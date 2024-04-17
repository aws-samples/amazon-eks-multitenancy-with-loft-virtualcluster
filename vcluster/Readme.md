##  Install the vCluster CLI
```

curl -L -o vcluster "https://github.com/loft-sh/vcluster/releases/latest/download/vcluster-darwin-arm64" && sudo install -c -m 0755 vcluster /usr/local/bin && rm -f vcluster

```
```
vcluster --version
```


##  Create your virtual cluster

<!-- vcluster create dev-cluster --namespace v-dev --connect=false   -f vclusterconfig.yaml  --connect=false   -->

```
cd <path>/aws-eks-loft-vcluster/vcluster/deployment  

vcluster create customer1-cluster --namespace v-customer1 --connect=false
vcluster create customer2-cluster --namespace v-customer2  --connect=false

```
## Connect

```
cd <path>/aws-eks-loft-vcluster/app/product/cluster-config
```
<!-- below command will connect to product-cluster and add ./kubeconfig.yaml to folder -->
```

    vcluster connect customer1-cluster -n v-customer1 --update-current=false 

    vcluster connect customer2-cluster -n v-customer2 --update-current=false 


    kubectl  --kubeconfig ./kubeconfig.yaml get namespaces

```

<!-- 
    vcluster create product-cluster --namespace v-product --upgrade  --connect=false  --isolate=true

    vcluster pause product-cluster -n v-product
    vcluster resume product-cluster -n v-product

    vcluster create sale-cluster --namespace v-sale --upgrade  --connect=false  --isolate=true

    vcluster pause sale-cluster -n v-sale
    vcluster resume sale-cluster -n v-sale 
-->
```
cd <path>/vcluster/deployment/cluster/customer1
```
## Deploy app

k --kubeconfig ./kubeconfig.yaml create ns app-product
kubectl  --kubeconfig ./kubeconfig.yaml apply -f ./product/product.yaml


k --kubeconfig ./kubeconfig.yaml create ns app-sale
kubectl  --kubeconfig ./kubeconfig.yaml apply -f ./sale/sale.yaml
k --kubeconfig ./kubeconfig.yaml -n app-sale exec cust1-sale-7d45967965-zbx7b -- curl http://172.16.127.20


<!-- - ssh on container
    kubectl exec --stdin --tty {podname} -- /bin/bash

     k --kubeconfig ./kubeconfig.yaml exec --stdin --tty product-7695d46444-pv46n -n app-product -- /bin/bash
     k --kubeconfig ./kubeconfig.yaml exec --stdin --tty sale-5fd77b9449-btg28 -n app-sales -- /bin/bash

- check api 
    curl http://localhost/ping
    curl http://localhost/list
-->

```
- Use `vcluster disconnect` to return to your previous kube context
```


## vcluster create has config options for specific cases:

    Use --expose to create a vCluster in a remote cluster with an externally accessible LoadBalancer.

    vcluster create my-vcluster --expose

    Use -f to use an additional Helm values.yaml with extra chart options to deploy vCluster.

    vcluster create my-vcluster -f values.yaml

    Use --distro to specify either k0s or vanilla k8s as a backing virtual cluster.

    vcluster create my-vcluster --distro k8s

    Use --isolate to create an isolated environment for the vCluster workloads

    vcluster create my-vcluster --isolate
    vcluster delete my-vcluster -n vcluster-my-vcluster   --delete-namespace

##  List vCluster
vcluster list

##  vCluster Delete

```
vcluster delete customer1-cluster -n v-customer1   --delete-namespace
vcluster delete customer2-cluster -n v-customer2   --delete-namespace


k config get-contexts
k config set-context akaasif-Isengard@vcluster-demo.ap-southeast-2.eksctl.io 

kubectl config use-context akaasif-Isengard@vcluster-demo.ap-southeast-2.eksctl.io
kubectl config use-context akaasif-Isengard@vcluster-demo-2.us-east-2.eksctl.io
```
<p align="center">
  <img  src="https://github.com/khanasif1/aws-eks-loft-vcluster/blob/main/architetcure/RefArchitecture.svg">
</p>

##  Network policy


```
cd <path>/aws-eks-loft-vcluster/vcluster/deployment/policy
```

- Create network policy so that product cluster does not talk to sale cluster
 
- Apply Policy

```
    kubectl  apply -f ../policy/customer1-deny-all-external.yaml  
    kubectl  apply -f ../policy/customer2-deny-all-external.yaml  
```

- Test Policy

```
    k --kubeconfig ./customer1/kubeconfig.yaml -n app-product exec cust1-product-7899b7cd9f-7m8fs -- curl http://172.16.127.18 cust1-prod-->cust1-sale -- WORKS
    k --kubeconfig ./customer1/kubeconfig.yaml -n app-product exec cust1-product-7899b7cd9f-7m8fs -- curl http://172.16.106.17 cust1-prod-->cust2-prod -- FAILS 
    k --kubeconfig ./customer2/kubeconfig.yaml -n app-product exec cust2-product-785c9f5db4-nf27k -- curl http://172.16.106.15 cust2-prod-->cust1-prod -- FAILS
    k --kubeconfig ./customer2/kubeconfig.yaml -n app-product exec cust2-product-785c9f5db4-nf27k -- curl http://172.16.127.20 cust2-prod-->cust2-sale -- WORKS

```