#!/bin/bash

if [ "$1" == "" ]; then
	export NS=kubeflow-user-example-com
	echo "Argument not provided, assuming default user namespace $NS ..."
else
	export NS=$1
fi

if [ "$2" == "" ]; then
	echo "CLUSTER_NAME Argument not provided. Please provide a valid cluster name."
	exit 1
else
	export CLUSTER_NAME=$2
fi

if [ "$3" == "" ]; then
	echo "CLUSTER_REGION Argument not provided. Please provide a valid cluster region name"
else
	export CLUSTER_REGION=$3
fi

#1. An OIDC provider must exist for your cluster to use IRSA. Create an OIDC provider and associate it with for your Amazon EKS cluster by running the following command, if your cluster doesn’t already have one:

eksctl utils associate-iam-oidc-provider --cluster ${CLUSTER_NAME} \
--region ${CLUSTER_REGION} --approve

#2. Once you have the IAM OIDC Provider associated with the cluster, to create a IAM role bound to a service account, run:

eksctl create iamserviceaccount \
--cluster=${CLUSTER_NAME} \
--name=default-editor \
--namespace=kubeflow-user-example-com \
--attach-policy-arn=arn:aws:iam::aws:policy/AmazonSageMakerFullAccess \
--attach-policy-arn=arn:aws:iam::aws:policy/AmazonS3FullAccess \
--attach-policy-arn=arn:aws:iam::aws:policy/IAMFullAccess \
--override-existing-serviceaccounts \
--approve

#3. Enable authentication of the Pipelines SDK to Kubeflow Pipelines API by injecting the required ServiceAccount token volume into your notebook pod using Kubeflow PodDefault custom resource:

echo ""
echo "Creating pod-default for namespace $NS ..."

printf "
apiVersion: kubeflow.org/v1alpha1
kind: PodDefault
metadata:
  name: access-ml-pipeline
  namespace: ${NS}
spec:
  desc: \"Allow access to Kubeflow Pipelines\"
  selector:
    matchLabels:
      access-ml-pipeline: \"true\"
  volumes:
  - name: volume-kf-pipeline-token
    projected:
      sources:
      - serviceAccountToken:
          path: token
          expirationSeconds: 7200
          audience: pipelines.kubeflow.org
  volumeMounts:
  - mountPath: /var/run/secrets/kubeflow/pipelines
    name: volume-kf-pipeline-token
    readOnly: true
  env:
  - name: KF_PIPELINES_SA_TOKEN_PATH
    value: /var/run/secrets/kubeflow/pipelines/token
 " > ./user-profile-config.yaml

kubectl apply -f ./user-profile-config.yaml
