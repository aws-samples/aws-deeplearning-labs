#!/bin/bash

source ~/.bash_profile
source ~/.bashrc

export CLUSTER_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')
CLUSTER_RAND=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 3 ; echo '')
export CLUSTER_NAME=eks-$CLUSTER_RAND
aws configure --profile=kubeflow set default.region ${CLUSTER_REGION}
export AWS_PROFILE=kubeflow
export KUBEFLOW_RELEASE_VERSION=v1.6.0
export AWS_RELEASE_VERSION=main
aws sts get-caller-identity

git clone https://github.com/awslabs/kubeflow-manifests.git && cd kubeflow-manifests
git checkout ${AWS_RELEASE_VERSION}
git clone --branch ${KUBEFLOW_RELEASE_VERSION} https://github.com/kubeflow/manifests.git upstream
make install-tools
alias python=python3.8
cd deployments/vanilla/terraform

cat <<EOF > sample.auto.tfvars
cluster_name="${CLUSTER_NAME}"
cluster_region="${CLUSTER_REGION}"
EOF

echo "export AWS_CLUSTER_NAME=${CLUSTER_NAME}" | tee -a ~/.bash_profile
echo "export AWS_REGION=${CLUSTER_REGION}" | tee -a ~/.bash_profile

aws sts get-caller-identity

terraform init && terraform plan
make deploy
