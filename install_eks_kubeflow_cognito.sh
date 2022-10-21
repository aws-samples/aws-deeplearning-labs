#!/bin/bash

source ~/.bash_profile
source ~/.bashrc

# Region to create the cluster in
export CLUSTER_REGION=us-west-2
# Name of the cluster to create
export CLUSTER_NAME=eks-kubeflow-161
# AWS access key id of the static credentials used to authenticate the Minio Client
export TF_VAR_minio_aws_access_key_id=
# AWS secret access key of the static credentials used to authenticate the Minio Client
export TF_VAR_minio_aws_secret_access_key=
# Name of an existing Route53 root domain (e.g. example.com)
export ROOT_DOMAIN=kkhurmi.people.aws.dev
# Name of the subdomain to create (e.g. platform.example.com)
export SUBDOMAIN=kube.kkhurmi.people.aws.dev
# Name of the cognito user pool to create
export USER_POOL_NAME=kubeflow-users
# true/false flag to configure and deploy with RDS
export USE_RDS="true"
# true/false flag to configure and deploy with S3
export USE_S3="true"
# true/false flag to configure and deploy with Cognito
export USE_COGNITO="true"
# Load Balancer Scheme
export LOAD_BALANCER_SCHEME=internet-facing

echo $CLUSTER_NAME

export KUBEFLOW_RELEASE_VERSION=v1.6.1
export AWS_RELEASE_VERSION=v1.6.1-aws-b1.0.0

git clone https://github.com/awslabs/kubeflow-manifests.git

cd kubeflow-manifests

git checkout ${AWS_RELEASE_VERSION}
git clone --branch ${KUBEFLOW_RELEASE_VERSION} https://github.com/kubeflow/manifests.git upstream

make install-tools

alias python=python3.8

cd deployments/cognito-rds-s3/terraform

cat <<EOF > sample.auto.tfvars
cluster_name="${CLUSTER_NAME}"
cluster_region="${CLUSTER_REGION}"
generate_db_password="true"
aws_route53_root_zone_name="${ROOT_DOMAIN}"
aws_route53_subdomain_zone_name="${SUBDOMAIN}"
cognito_user_pool_name="${USER_POOL_NAME}"
use_rds="${USE_RDS}"
use_s3="${USE_S3}"
use_cognito="${USE_COGNITO}"
load_balancer_scheme="${LOAD_BALANCER_SCHEME}"

# The below values are set to make cleanup easier but are not recommended for production
deletion_protection="false"
secret_recovery_window_in_days="0"
force_destroy_s3_bucket="true"
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


