#!/bin/bash

source ~/.bash_profile
source ~/.bashrc

export KUBEFLOW_RELEASE_VERSION=v1.6.0
export AWS_RELEASE_VERSION=main

git clone https://github.com/awslabs/kubeflow-manifests.git && cd kubeflow-manifests
git checkout ${AWS_RELEASE_VERSION}
git clone --branch ${KUBEFLOW_RELEASE_VERSION} https://github.com/kubeflow/manifests.git upstream
make install-tools
alias python=python3.8
#cd deployments/vanilla/terraform

export CLUSTER_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
CLUSTER_RAND=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 3 ; echo '')
export CLUSTER_NAME=eks-$CLUSTER_RAND


cat <<EOF > sample.auto.tfvars
cluster_name="${CLUSTER_NAME}"
cluster_region="${CLUSTER_REGION}"
EOF

echo "export AWS_CLUSTER_NAME=${CLUSTER_NAME}" | tee -a ~/.bash_profile
echo "export AWS_REGION=${CLUSTER_REGION}" | tee -a ~/.bash_profile

aws configure set region ${CLUSTER_REGION} --profile kubeflow
aws configure set output json --profile kubeflow
export AWS_PROFILE=kubeflow
aws sts get-caller-identity

#terraform init && terraform plan
#make deploy

eksctl create cluster \
--name ${CLUSTER_NAME} \
--version 1.22 \
--region ${CLUSTER_REGION} \
--nodegroup-name linux-nodes \
--node-type m5.xlarge \
--nodes 5 \
--nodes-min 5 \
--nodes-max 10 \
--managed \
--with-oidc

eksctl utils associate-iam-oidc-provider --cluster ${CLUSTER_NAME} \
--region ${CLUSTER_REGION} --approve

make deploy-kubeflow INSTALLATION_OPTION=kustomize DEPLOYMENT_OPTION=vanilla

export NODE_IAM_ROLE_NAME=$(eksctl get iamidentitymapping --cluster ${CLUSTER_NAME} | grep  arn | awk  '{print $1}' | egrep -o eks.*)
echo $NODE_IAM_ROLE_NAME

aws iam attach-role-policy --role-name ${NODE_IAM_ROLE_NAME} --policy-arn arn:aws:iam::aws:policy/AmazonSageMakerFullAccess
aws iam attach-role-policy --role-name ${NODE_IAM_ROLE_NAME} --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
aws iam attach-role-policy --role-name ${NODE_IAM_ROLE_NAME} --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess
aws iam attach-role-policy --role-name ${NODE_IAM_ROLE_NAME} --policy-arn arn:aws:iam::aws:policy/IAMReadOnlyAccess


