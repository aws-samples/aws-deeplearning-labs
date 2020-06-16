#!/bin/bash
#Install KubeFlow on EKS

source ~/.bash_profile

echo "eks cluster name is $AWS_CLUSTER_NAME"
echo "aws region is $AWS_REGION"

kubectl get nodes # if we see our 3 nodes, we know we have authenticated correctly

STACK_NAME=$(eksctl get nodegroup --cluster ${AWS_CLUSTER_NAME} -o json | jq -r '.[].StackName')
ROLE_NAME=$(aws cloudformation describe-stack-resources --stack-name $STACK_NAME | jq -r '.StackResources[] | select(.ResourceType=="AWS::IAM::Role") | .PhysicalResourceId')
echo "export ROLE_NAME=${ROLE_NAME}" | tee -a ~/.bash_profile

export NODEGROUP_NAME=$(eksctl get nodegroups --cluster ${AWS_CLUSTER_NAME} -o json | jq -r '.[0].Name')
eksctl scale nodegroup --cluster ${AWS_CLUSTER_NAME} --name $NODEGROUP_NAME --nodes 6 --nodes-max 10

curl --silent --location "https://github.com/kubeflow/kfctl/releases/download/v1.0.1/kfctl_v1.0.1-0-gf3edb9b_linux.tar.gz" | tar xz -C /tmp
sudo cp -v /tmp/kfctl /usr/local/bin

cat << EoF > kf-install.sh
export AWS_CLUSTER_NAME=\${AWS_CLUSTER_NAME}
export KF_NAME=\${AWS_CLUSTER_NAME}

export BASE_DIR=/home/ec2-user/environment
export KF_DIR=\${BASE_DIR}/\${KF_NAME}

# export CONFIG_URI="https://raw.githubusercontent.com/kubeflow/manifests/v1.0-branch/kfdef/kfctl_aws_cognito.v1.0.1.yaml"
export CONFIG_URI="https://raw.githubusercontent.com/kubeflow/manifests/v1.0-branch/kfdef/kfctl_aws.v1.0.1.yaml"

export CONFIG_FILE=\${KF_DIR}/kfctl_aws.yaml
EoF

source kf-install.sh

mkdir -p ${KF_DIR}
cd ${KF_DIR} && wget -O kfctl_aws.yaml $CONFIG_URI

sed -i '/region: us-west-2/ a \      enablePodIamPolicy: true' ${CONFIG_FILE}

sed -i -e 's/kubeflow-aws/'"$AWS_CLUSTER_NAME"'/' ${CONFIG_FILE}
sed -i "s@us-west-2@$AWS_REGION@" ${CONFIG_FILE}

sed -i "s@roles:@#roles:@" ${CONFIG_FILE}
sed -i "s@- eksctl-${AWS_CLUSTER_NAME}-nodegroup-ng-a2-NodeInstanceRole-xxxxxxx@#- eksctl-${AWS_CLUSTER_NAME}-nodegroup-ng-a2-NodeInstanceRole-xxxxxxx@" ${CONFIG_FILE}

curl -o aws-iam-authenticator https://amazon-eks.s3.us-west-2.amazonaws.com/1.15.10/2020-02-22/bin/linux/amd64/aws-iam-authenticator
chmod +x aws-iam-authenticator
sudo mv aws-iam-authenticator /usr/local/bin

eksctl utils write-kubeconfig --cluster ${AWS_CLUSTER_NAME}
cd ${KF_DIR} && kfctl apply -V -f ${CONFIG_FILE}
kubectl -n kubeflow get all


export NODE_IAM_ROLE_NAME=$(eksctl get iamidentitymapping --cluster ${AWS_CLUSTER_NAME} | grep  arn | awk  '{print $1}' | egrep -o eks.*)
aws iam attach-role-policy --role-name ${NODE_IAM_ROLE_NAME} --policy-arn arn:aws:iam::aws:policy/AmazonSageMakerFullAccess
aws iam attach-role-policy --role-name ${NODE_IAM_ROLE_NAME} --policy-arn arn:aws:iam::aws:policy/AmazonS3FullAccess
