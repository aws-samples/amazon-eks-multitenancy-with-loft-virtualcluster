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
cd <path>/amazon-eks-multitenancy-with-loft-virtualcluster/vcluster/deployment  
kubectl create namespace  v-customer1
kubectl create namespace  v-customer2

vcluster create customer1-cluster --namespace v-customer1 --connect=false
vcluster create customer2-cluster --namespace v-customer2 --distro k0s --connect=false

```
## Connect
vcluster list
```
cd <path>/amazon-eks-multitenancy-with-loft-virtualcluster/customercluster/deployment/cluster/{customer1 OR 2}
```
<!-- below command will connect to product-cluster and add ./kubeconfig.yaml to folder -->
```

    vcluster connect customer1-cluster -n v-customer1 --update-current=false 

    vcluster connect customer2-cluster -n v-customer2 --update-current=false 


    kubectl  --kubeconfig ./kubeconfig.yaml get namespaces
    kubectl replace --raw "/api/v1/namespaces/v-customer2/finalize" -f ./tmp.json

```

```
cd <path>/vcluster/deployment/cluster/customer1

```
## Deploy app

```

kubectl --kubeconfig ./kubeconfig.yaml create ns app-product
kubectl  --kubeconfig ./kubeconfig.yaml apply -f ./product/product.yaml
kubectl --kubeconfig ./kubeconfig.yaml -n app-product get pod  
kubectl --kubeconfig ./kubeconfig.yaml -n app-product exec {product pod name}  -- curl http://localhost

kubectl --kubeconfig ./kubeconfig.yaml create ns app-sale
kubectl  --kubeconfig ./kubeconfig.yaml apply -f ./sale/sale.yaml
kubectl --kubeconfig ./kubeconfig.yaml -n app-sale get pod  
kubectl --kubeconfig ./kubeconfig.yaml -n app-sale exec {sales pod name} -- curl http://localhost

```

```
- Use `vcluster disconnect` to return to your previous kube context
```


## vcluster create has config options for specific cases (optional):

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

```
cd <path>/vcluster/deployment/cluster
<!-- Get Pod Name and Ip -->
kubectl --kubeconfig ./kubeconfig.yaml -n app-product get pod  -o wide  <!-- customer1 -->
kubectl --kubeconfig ./kubeconfig.yaml -n app-sale get pod  -o wide <!-- customer1 -->
kubectl --kubeconfig ./kubeconfig.yaml -n app-product get pod  -o wide <!-- customer2 -->
kubectl --kubeconfig ./kubeconfig.yaml -n app-sale get pod  -o wide <!-- customer1 -->

```



```
    kubectl --kubeconfig ./customer1/kubeconfig.yaml -n app-product exec {customer 1 product pod} -- curl http://{customer1 sales pod ip}     #team-a-prod-->team-a-sale -- WORKS
    kubectl --kubeconfig ./customer1/kubeconfig.yaml -n app-product exec customer 1 product pod}    -- curl http://{customer2 product pod ip} #team-a-prod-->cust2-prod -- FAILS 
    kubectl --kubeconfig ./customer2/kubeconfig.yaml -n app-sale exec {customer 2 sales pod} -- curl http://{customer 1 sales pod ip}         #cust2-sale-->team-a-sale -- FAILS
    kubectl --kubeconfig ./customer2/kubeconfig.yaml -n app-product exec {customer 2 product pod} -- curl http://{customer 2 sales pod}       #cust2-prod-->cust2-sale -- WORKS

```


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
