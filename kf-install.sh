export AWS_CLUSTER_NAME=${AWS_CLUSTER_NAME}
export KF_NAME=${AWS_CLUSTER_NAME}

export BASE_DIR=/home/ec2-user/environment
export KF_DIR=${BASE_DIR}/${KF_NAME}

# export CONFIG_URI="https://raw.githubusercontent.com/kubeflow/manifests/v1.2-branch/kfdef/kfctl_aws_cognito.v1.2.0.yaml"
export CONFIG_URI="https://raw.githubusercontent.com/kubeflow/manifests/v1.2-branch/kfdef/kfctl_aws.v1.2.0.yaml"

export CONFIG_FILE=${KF_DIR}/kfctl_aws.yaml
