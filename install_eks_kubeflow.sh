#!/bin/bash

source ~/.bash_profile
source ~/.bashrc

export KUBEFLOW_RELEASE_VERSION=v1.6.1
export AWS_RELEASE_VERSION=v1.6.1-aws-b1.0.0

git clone https://github.com/awslabs/kubeflow-manifests.git && cd kubeflow-manifests
git checkout ${AWS_RELEASE_VERSION}
git clone --branch ${KUBEFLOW_RELEASE_VERSION} https://github.com/kubeflow/manifests.git upstream
make install-tools
alias python=python3.8
cd deployments/vanilla/terraform

export CLUSTER_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
CLUSTER_RAND=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 3 ; echo '')
export CLUSTER_NAME=eks-$CLUSTER_RAND


cat <<EOF > sample.auto.tfvars
cluster_name="${CLUSTER_NAME}"
cluster_region="${CLUSTER_REGION}"
EOF

echo "export AWS_CLUSTER_NAME=${CLUSTER_NAME}" | tee -a ~/.bash_profile
echo "export AWS_REGION=${CLUSTER_REGION}" | tee -a ~/.bash_profile
echo "export NODE_IAM_ROLE=${CLUSTER_NAME}-managed-ondemand-cpu" | tee -a ~/.bash_profile

aws configure set region ${CLUSTER_REGION} --profile kubeflow
aws configure set output json --profile kubeflow
export AWS_PROFILE=kubeflow
aws sts get-caller-identity

terraform init && terraform plan
make deploy

source ~/.bash_profile
source ~/.bashrc

aws iam attach-role-policy --role-name ${NODE_IAM_ROLE} --policy-arn arn:aws:iam::aws:policy/AmazonSageMakerFullAccess
aws iam attach-role-policy --role-name ${NODE_IAM_ROLE} --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
aws iam attach-role-policy --role-name ${NODE_IAM_ROLE} --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess
aws iam attach-role-policy --role-name ${NODE_IAM_ROLE} --policy-arn arn:aws:iam::aws:policy/IAMReadOnlyAccess

# Create SageMaker Execution role

cat << EoF > trust.json
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "",
            "Effect": "Allow",
            "Principal": {
                "Service": "sagemaker.amazonaws.com"
            },
            "Action": "sts:AssumeRole"
        }
    ]
}
EoF

aws iam create-role --role-name sagemakerrole --assume-role-policy-document file://trust.json --output=text
aws iam attach-role-policy --role-name sagemakerrole --policy-arn arn:aws:iam::aws:policy/AmazonSageMakerFullAccess
aws iam attach-role-policy --role-name sagemakerrole --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess

# Getting EKS Cluster Node Group role with aws APIs. 

EKS_CLUSTER_NGNAME=$(aws eks list-nodegroups --cluster-name $CLUSTER_NAME | jq -r '.nodegroups[0]')
echo $EKS_CLUSTER_NGNAME
EKS_NODE_ROLE=$(aws eks describe-nodegroup --cluster-name $CLUSTER_NAME --nodegroup-name $EKS_CLUSTER_NGNAME | jq -r '.nodegroup.nodeRole' | grep -o 'eks.*')
echo $EKS_NODE_ROLE


