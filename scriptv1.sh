#!/bin/bash
# Install EKS
# Create Cloud9 workspace with relevant IAM role, remove any local references to credentials.

sudo yum -y install jq gettext bash-completion ec2-instance-connect

export AWS_REGION=$(curl -s 169.254.169.254/latest/dynamic/instance-identity/document | jq -r '.region')

CLUSTER_RAND=$(head /dev/urandom | tr -dc A-Za-z0-9 | head -c 13 ; echo '')

export AWS_CLUSTER_NAME=eksworkshop-$CLUSTER_RAND

aws configure set default.region ${AWS_REGION}
#aws configure set aws_output json

sudo curl --silent --location -o /usr/local/bin/kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.14.6/2019-08-22/bin/linux/amd64/kubectl
sudo chmod +x /usr/local/bin/kubectl
sudo curl --silent --location -o /usr/local/bin/aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/aws-iam-authenticator
sudo chmod +x /usr/local/bin/aws-iam-authenticator

/usr/local/bin/kubectl completion bash >>  ~/.bash_completion
. /etc/profile.d/bash_completion.sh
. ~/.bash_completion

curl --silent --location "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp

sudo mv -v /tmp/eksctl /usr/local/bin
eksctl version

eksctl completion bash >> ~/.bash_completion
. /etc/profile.d/bash_completion.sh
. ~/.bash_completion

ssh-keygen -t rsa -q -P "" -f ~/.ssh/id_rsa-${AWS_CLUSTER_NAME}

aws ec2 import-key-pair --key-name "${AWS_CLUSTER_NAME}" --public-key-material file://~/.ssh/id_rsa-${AWS_CLUSTER_NAME}.pub

aws kms create-alias --alias-name alias/${AWS_CLUSTER_NAME} --target-key-id $(aws kms create-key --query KeyMetadata.Arn --output text)

export MASTER_ARN=$(aws kms describe-key --key-id alias/${AWS_CLUSTER_NAME} --query KeyMetadata.Arn --output text)

echo "export MASTER_ARN=${MASTER_ARN}" | tee -a ~/.bash_profile

echo "export AWS_CLUSTER_NAME=${AWS_CLUSTER_NAME}" | tee -a ~/.bash_profile

echo "export AWS_REGION=${AWS_REGION}" | tee -a ~/.bash_profile

cat << EOF > ${AWS_CLUSTER_NAME}.yaml
---
apiVersion: eksctl.io/v1alpha5
kind: ClusterConfig

metadata:
  name: ${AWS_CLUSTER_NAME}
  region: ${AWS_REGION}

managedNodeGroups:
- name: nodegroup
  desiredCapacity: 3
  iam:
    withAddonPolicies:
      albIngress: true

secretsEncryption:
  keyARN: ${MASTER_ARN}
EOF

eksctl create cluster -f ${AWS_CLUSTER_NAME}.yaml
eksctl utils write-kubeconfig --cluster ${AWS_CLUSTER_NAME}
