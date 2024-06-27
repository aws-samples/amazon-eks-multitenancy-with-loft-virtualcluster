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
kubectl create namespace  v-team-a
kubectl create namespace  v-team-b

vcluster create team-a-cluster --namespace v-team-a --connect=false
vcluster create team-b-cluster --namespace v-team-b --distro k0s --connect=false

```
## Connect
vcluster list
```
cd <path>/amazon-eks-multitenancy-with-loft-virtualcluster/customercluster/deployment/cluster/{team-a OR 2}
```
<!-- below command will connect to product-cluster and add ./kubeconfig.yaml to folder -->
```

    vcluster connect team-a-cluster -n v-team-a --update-current=false 

    vcluster connect team-b-cluster -n v-team-b --update-current=false 


    kubectl  --kubeconfig ./kubeconfig.yaml get namespaces
    kubectl replace --raw "/api/v1/namespaces/v-team-b/finalize" -f ./tmp.json

```

```
cd <path>/vcluster/deployment/cluster/team-a

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
    kubectl  apply -f ./customercluster/deployment/policy/team-a-deny-all-external.yaml  
    kubectl  apply -f ./customercluster/deployment/policy/team-b-deny-all-external.yaml  


    kubectl  delete -f ./customercluster/deployment/policy/team-a-deny-all-external.yaml  
    kubectl  delete -f ./customercluster/deployment/policy/team-b-deny-all-external.yaml  
```

- Test Policy

```
cd <path>/vcluster/deployment/cluster
<!-- Get Pod Name and Ip -->
kubectl --kubeconfig ./kubeconfig.yaml -n app-product get pod  -o wide  <!-- team-a -->
kubectl --kubeconfig ./kubeconfig.yaml -n app-sale get pod  -o wide <!-- team-a -->
kubectl --kubeconfig ./kubeconfig.yaml -n app-product get pod  -o wide <!-- team-b -->
kubectl --kubeconfig ./kubeconfig.yaml -n app-sale get pod  -o wide <!-- team-a -->

```



```
    kubectl --kubeconfig ./team-a/kubeconfig.yaml -n app-product exec {customer 1 product pod} -- curl http://{team-a sales pod ip}     #team-a-prod-->team-a-sale -- WORKS
    kubectl --kubeconfig ./team-a/kubeconfig.yaml -n app-product exec customer 1 product pod}    -- curl http://{team-b product pod ip} #team-a-prod-->team-b-prod -- FAILS 
    kubectl --kubeconfig ./team-b/kubeconfig.yaml -n app-sale exec {customer 2 sales pod} -- curl http://{customer 1 sales pod ip}         #team-b-sale-->team-a-sale -- FAILS
    kubectl --kubeconfig ./team-b/kubeconfig.yaml -n app-product exec {customer 2 product pod} -- curl http://{customer 2 sales pod}       #team-b-prod-->team-b-sale -- WORKS

```


##  vCluster Delete

```
vcluster delete team-a-cluster -n v-team-a   --delete-namespace
vcluster delete team-b-cluster -n v-team-b   --delete-namespace

k config get-contexts
k config set-context akaasif-Isengard@vcluster-demo.ap-southeast-2.eksctl.io 

kubectl config use-context akaasif-Isengard@vcluster-demo.ap-southeast-2.eksctl.io
kubectl config use-context akaasif-Isengard@vcluster-demo-2.us-east-2.eksctl.io
```
# Delete Namespace when stuck

```    
     kubectl  --kubeconfig ./kubeconfig.yaml get namespaces
     kubectl get namespace v-team-a -o json > tmp1.json
     kubectl get namespace v-team-b -o json > tmp2.json

     kubectl replace --raw "/api/v1/namespaces/v-team-a/finalize" -f ./tmp1.json
     kubectl replace --raw "/api/v1/namespaces/v-team-b/finalize" -f ./tmp2.json
```
