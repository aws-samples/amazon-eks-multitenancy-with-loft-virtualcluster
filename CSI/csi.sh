cluster_name=vcluster-demo-1 

#OIDC
    oidc_id=$(aws eks describe-cluster --name $cluster_name --region ap-southeast-2 --query "cluster.identity.oidc.issuer" --output text | cut -d '/' -f 5)
    echo $oidc_id

    # Determine whether an IAM OIDC provider with your cluster's issuer ID is already in your account.
    aws iam list-open-id-connect-providers | grep $oidc_id | cut -d "/" -f4

    # Create an IAM OIDC identity provider for your cluster with the following command.
    eksctl utils associate-iam-oidc-provider --cluster $cluster_name --region ap-southeast-2 --approve


# Attach CSI policy to EC2 role
    
    aws iam attach-role-policy --role-name eksctl-vcluster-demo-1-nodegroup-n-NodeInstanceRole-9Z1iabOMHDLB --policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy
    # eksctl create iamserviceaccount \
    #     --name ebs-csi-controller-sa \
    #     --namespace kube-system \
    #     --cluster $cluster_name \
    #     --region ap-southeast-2 \
    #     --role-name AmazonEKS_EBS_CSI_DriverRole \
    #     --role-only \
    #     --attach-policy-arn arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy \
    #     --approve


# An existing cluster. To see the required platform version, run the following command
aws eks describe-addon-versions --addon-name aws-ebs-csi-driver



eksctl create addon --name aws-ebs-csi-driver --cluster $cluster_name --region ap-southeast-2  \
--service-account-role-arn arn:aws:iam::809980971988:role/eksctl-vcluster-demo-1-nodegroup-n-NodeInstanceRole-9Z1iabOMHDLB --force
