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
kubectl create namespace  v-customer1
kubectl create namespace  v-customer2

vcluster create customer1-cluster --namespace v-customer1 --connect=false
vcluster create customer2-cluster --namespace v-customer2  --connect=false

kubectl create namespace  v-customer3
vcluster create customer3-cluster --namespace v-customer3 --connect=false
vcluster connect customer3-cluster -n v-customer3 --update-current=false 
vcluster delete customer3-cluster -n v-customer3   --delete-namespace
```
## Connect
vcluster list
```
cd <path>/aws-eks-loft-vcluster/app/product/cluster-config
```
<!-- below command will connect to product-cluster and add ./kubeconfig.yaml to folder -->
```

    vcluster connect customer1-cluster -n v-customer1 --update-current=false 

    vcluster connect customer2-cluster -n v-customer2 --update-current=false 


    kubectl  --kubeconfig ./kubeconfig.yaml get namespaces
    kubectl replace --raw "/api/v1/namespaces/v-customer2/finalize" -f ./tmp.json

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

```

kubectl --kubeconfig ./kubeconfig.yaml create ns app-product
kubectl  --kubeconfig ./kubeconfig.yaml apply -f ./product/product.yaml
kubectl --kubeconfig ./kubeconfig.yaml -n app-product get pod  
kubectl --kubeconfig ./kubeconfig.yaml -n app-product exec cust1-product-7d9dbf94df-jrc9g  -- curl http://localhost

kubectl --kubeconfig ./kubeconfig.yaml create ns app-sale
kubectl  --kubeconfig ./kubeconfig.yaml apply -f ./sale/sale.yaml
kubectl --kubeconfig ./kubeconfig.yaml -n app-sale get pod  
kubectl --kubeconfig ./kubeconfig.yaml -n app-sale exec cust2-sale-64485fcdb6-wkmlt -- curl http://localhost

```

<!-- kubectl  --kubeconfig ./kubeconfig.yaml delete -f ./product/product.yaml   
kubectl  --kubeconfig ./kubeconfig.yaml delete -f ./sale/sale.yaml   -->
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


##  List vCluster
vcluster list


<p align="center">
  <img  src="https://github.com/khanasif1/aws-eks-loft-vcluster/blob/main/architetcure/RefArchitecture.svg">
</p>

##  Network policy

https://docs.aws.amazon.com/eks/latest/userguide/managing-vpc-cni.html
https://docs.aws.amazon.com/eks/latest/userguide/cni-network-policy.html
https://docs.aws.amazon.com/eks/latest/userguide/cni-iam-role.html#cni-iam-role-create-role
https://docs.aws.amazon.com/eks/latest/userguide/enable-iam-roles-for-service-accounts.html
https://docs.aws.amazon.com/eks/latest/userguide/managing-add-ons.html#creating-an-add-on
```
cd <path>/aws-eks-loft-vcluster/vcluster/deployment/policy
```

- Create network policy so that product cluster does not talk to sale cluster
 
- Apply Policy

```
    kubectl  apply -f ./customercluster/deployment/policy/customer1-deny-all-external.yaml  
    kubectl  apply -f ./customercluster/deployment/policy/customer2-deny-all-external.yaml  


    kubectl  delete -f ./customercluster/deployment/policy/customer1-deny-all-external.yaml  
    kubectl  delete -f ./customercluster/deployment/policy/customer2-deny-all-external.yaml  
```

- Test Policy
cd <path>/vcluster/deployment/cluster
<!-- Get Pod Name and Ip -->
kubectl --kubeconfig ./kubeconfig.yaml -n app-product get pod  -o wide  <!-- customer1 -->
kubectl --kubeconfig ./kubeconfig.yaml -n app-sale get pod  -o wide <!-- customer1 -->
kubectl --kubeconfig ./kubeconfig.yaml -n app-product get pod  -o wide <!-- customer2 -->
kubectl --kubeconfig ./kubeconfig.yaml -n app-sale get pod  -o wide <!-- customer1 -->

kubectl --kubeconfig ./kubeconfig.yaml -n app-product exec cust1-product-7d9dbf94df-7hgv9 -- curl http://192.168.18.144
kubectl --kubeconfig ./kubeconfig.yaml -n app-product exec cust2-product-7c8999c64-jj7k6  -- curl http://192.168.75.114


```
    kubectl --kubeconfig ./customer1/kubeconfig.yaml -n app-product exec cust1-product-7d9dbf94df-jmv58 -- curl http://192.168.12.229   #cust1-prod-->cust1-sale -- WORKS
    kubectl --kubeconfig ./customer1/kubeconfig.yaml -n app-product exec cust1-product-7d9dbf94df-5bjl4    -- curl http://192.168.12.206 #cust1-prod-->cust2-prod -- FAILS 
    kubectl --kubeconfig ./customer2/kubeconfig.yaml -n app-sale exec cust2-sale-64485fcdb6-wkmlt -- curl http://192.168.12.229         #cust2-sale-->cust1-sale -- FAILS
    kubectl --kubeconfig ./customer2/kubeconfig.yaml -n app-product exec cust2-product-7c8999c64-fx9n4 -- curl http://192.168.0.191       #cust2-prod-->cust2-sale -- WORKS

```


kubectl get pods customer1-cluster-0 -n v-customer1 -o jsonpath='{.items[*].spec["initContainers", "containers"][*].name}'

kubectl get pods customer1-cluster-0 -n v-customer1 -o jsonpath='{.spec.containers[*].name}'
kubectl get pods -n v-customer1 -o jsonpath='{.items[*].spec.containers[*].name}'



kubectl get pod customer1-cluster-0 -n v-customer1  -o jsonpath='{.spec["initContainers", "containers"][*].name}'

kubectl get pods -n v-customer1 -o jsonpath='{range .items[*]}{"\n"}{.metadata.name}{":\t"}{range .spec.containers[*]}{.image}{", "}{end}{end}' |\
sort

kubectl get pods customer1-cluster-0 -n v-customer1 -o jsonpath='{.spec.containers[*].name}'

kubectl get pods customer1-cluster-0 -n v-customer1 -o=jsonpath='{range .spec.containers[*]}{.name}{"\n"}{end}'

kubectl describe pod customer1-cluster-0 -n v-customer1 | grep -E '^    [a-z]' | awk '{print $1}'


##  vCluster Delete

```
vcluster delete customer1-cluster -n v-customer1   --delete-namespace
vcluster delete customer2-cluster -n v-customer2   --delete-namespace

k config get-contexts
k config set-context akaasif-Isengard@vcluster-demo.ap-southeast-2.eksctl.io 

kubectl config use-context akaasif-Isengard@vcluster-demo.ap-southeast-2.eksctl.io
kubectl config use-context akaasif-Isengard@vcluster-demo-2.us-east-2.eksctl.io
```
# Delete Namespace when stuck

```    
     kubectl  --kubeconfig ./kubeconfig.yaml get namespaces
     kubectl get namespace v-customer1 -o json > tmp1.json
     kubectl get namespace v-customer2 -o json > tmp2.json

     kubectl replace --raw "/api/v1/namespaces/v-customer1/finalize" -f ./tmp1.json
     kubectl replace --raw "/api/v1/namespaces/v-customer2/finalize" -f ./tmp2.json
```
