#!/bin/bash
# Install Sagemaker Operators on EKS

source ~/.bash_profile

#Upgrade AWSCLI
sudo yum install python3 pip3 -y
sudo pip3 install --upgrade awscli
sudo pip3 install --upgrade numpy
source ~/.bashrc

export AWS_ACCOUNT=$(aws sts get-caller-identity --output text --query Account)
eksctl utils associate-iam-oidc-provider --cluster ${AWS_CLUSTER_NAME} --region ${AWS_REGION} --approve
export EKS_OIDC=$(aws eks describe-cluster --query cluster --name ${AWS_CLUSTER_NAME} --output text | grep OIDC | awk  '{print $2}' | grep -oP '(?<=https://oidc.eks.us-east-2.amazonaws.com/id/).*' )

cat << EoF > trust.json
{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Federated": "arn:aws:iam::${AWS_ACCOUNT}:oidc-provider/oidc.eks.${AWS_REGION}.amazonaws.com/id/${EKS_OIDC}"
    },
    "Action": "sts:AssumeRoleWithWebIdentity",
    "Condition": {
      "StringEquals": {
        "oidc.eks.${AWS_REGION}.amazonaws.com/id/${EKS_OIDC}:aud": "sts.amazonaws.com",
        "oidc.eks.${AWS_REGION}.amazonaws.com/id/${EKS_OIDC}:sub": "system:serviceaccount:sagemaker-k8s-operator-system:sagemaker-k8s-operator-default"
      }
    }
  }]
}
EoF

aws iam create-role --role-name sagemaker-${AWS_CLUSTER_NAME} --assume-role-policy-document file://trust.json --output=text

aws iam attach-role-policy --role-name sagemaker-${AWS_CLUSTER_NAME} --policy-arn arn:aws:iam::aws:policy/AmazonSageMakerFullAccess

wget https://raw.githubusercontent.com/aws/amazon-sagemaker-operator-for-k8s/master/release/rolebased/installer.yaml

export SagemakerRoleArn=$(aws iam get-role --role-name sagemaker-${AWS_CLUSTER_NAME} --output text | grep  role | awk  '{print $2}')
echo ${SagemakerRoleArn}
# Edit the installer.yaml file to replace eks.amazonaws.com/role-arn. Replace the ARN here with the Amazon Resource Name (ARN) for the OIDC-based role you’ve created.

sed -i "s|arn:aws:iam::123456789012:role.*|$SagemakerRoleArn|" installer.yaml

eksctl utils write-kubeconfig --cluster ${AWS_CLUSTER_NAME}

kubectl apply -f installer.yaml

sleep 15

kubectl get crd | grep sagemaker

kubectl -n sagemaker-k8s-operator-system get pods

export os="linux"

wget https://amazon-sagemaker-operator-for-k8s-us-east-1.s3.amazonaws.com/kubectl-smlogs-plugin/v1/${os}.amd64.tar.gz
tar xvzf ${os}.amd64.tar.gz

# Move binaries to a directory in your homedir.
mkdir ~/sagemaker-k8s-bin
cp ./kubectl-smlogs.${os}.amd64/kubectl-smlogs ~/sagemaker-k8s-bin/.

# This line will add the binaries to your PATH in your .bashrc.

echo 'export PATH=$PATH:~/sagemaker-k8s-bin' >> ~/.bashrc

# Source your .bashrc to update environment variables:
source ~/.bashrc

kubectl smlogs

export assume_role_policy_document='{
  "Version": "2012-10-17",
  "Statement": [{
    "Effect": "Allow",
    "Principal": {
      "Service": "sagemaker.amazonaws.com"
    },
    "Action": "sts:AssumeRole"
  }]
}'

aws iam create-role --role-name sm-k8-role-${AWS_CLUSTER_NAME} --assume-role-policy-document file://<(echo "$assume_role_policy_document")
aws iam attach-role-policy --role-name sm-k8-role-${AWS_CLUSTER_NAME} --policy-arn arn:aws:iam::aws:policy/AmazonSageMakerFullAccess
aws iam attach-role-policy --role-name sm-k8-role-${AWS_CLUSTER_NAME} --policy-arn arn:aws:iam::aws:policy/AdministratorAccess
