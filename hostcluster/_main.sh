#******************
# Chain Deployment
#******************
source ./hostcluster/environmentVariables.sh

echo "${BLUE}Please check the details before proceeding \n AWS Account: ${ACCOUNT_ID} \n AWS Region for deployment : ${AWS_REGION} \n
echo "EBS CSI driver as well as Calico will be deployed with the cluster" \n 
${RED}Casesenstive ${BLUE}Press Y = Proceed or N = Cancel"
echo "${CYAN}Response: "
read user_input
Entry='Y'
if [[ "$user_input" == *"$Entry"* ]]; then
        echo "Deploy EKS"
        echo "${GREEN} Proceed deployment"
        echo "Cluster!!"
        echo "${YELLOW}print cluster Parameters \n"
        echo $CLUSTER_NAME  "|"  $AWS_REGION "|"  $ACCOUNT_ID
        chmod u+x ./hostcluster/deployment/createCluster.sh
        ./hostcluster/deployment/createCluster.sh
        
        CHECK_CLUSTER=$(aws eks list-clusters --region ${AWS_REGION} | jq -r ".clusters" | grep $CLUSTER_NAME || true)
        if [ ! -z $CHECK_CLUSTER ];then
        echo "${BLUE}Cluster Exists, ***deploying CSI and CNI***"
        
        chmod u+x ./hostcluster/deployment/csi/csi.sh
        ./hostcluster/deployment/csi/csi.sh

        chmod u+x ./hostcluster/deployment/cni/calico.sh
        ./hostcluster/deployment/cni/calico.sh

        # Cordon the node to mark it unschedulable
        kubectl cordon ip-192-168-32-19.us-east-2.compute.internal

        # Drain the node to safely evict all pods
        kubectl drain ip-192-168-32-19.us-east-2.compute.internal --ignore-daemonsets --delete-local-data

        # Uncordon the node to mark it schedulable again
        kubectl uncordon ip-192-168-32-19.us-east-2.compute.internal

        # Cordon the node to mark it unschedulable
        kubectl cordon ip-192-168-77-99.us-east-2.compute.internal

        # Drain the node to safely evict all pods
        kubectl drain ip-192-168-77-99.us-east-2.compute.internal --ignore-daemonsets --delete-local-data

        # Uncordon the node to mark it schedulable again
        kubectl uncordon ip-192-168-77-99.us-east-2.compute.internal      




        else
        echo "${RED}Cluster does not exists, ***skipping CSI CNI***"
        echo "${RED}Exit Deployment"
        fi
else

    echo "${RED}Cancel deployment"
fi

