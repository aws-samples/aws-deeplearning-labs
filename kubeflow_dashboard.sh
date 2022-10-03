#!/bin/bash

source ~/.bash_profile
source ~/.bashrc

cd /home/ubuntu/environment/eks-kubeflow-cloudformation-quick-start/kubeflow-manifests/deployments/vanilla/terraform
$(terraform output -raw configure_kubectl)

if [ "$1" == "" ]; then
	export NS=kubeflow-user-example-com
	echo "Argument not provided, assuming default user namespace $NS ..."
else
	export NS=$1
fi

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

ns_cnt=$(kubectl get namespace | grep $NS | wc -l)
while [ "$ns_cnt" == "0" ]; do
	echo "Waiting for namespace $NS to be created ..."
	sleep 15
	ns_cnt=$(kubectl get namespace | grep $NS | wc -l)
done

if [ "$ns_cnt" == "1" ]; then
	kubectl apply -f ./user-profile-config.yaml
else
	echo "The name $NS must match exactly one namespace"
	echo "Please specify a correct name and try again."
fi

rm -f ./user-profile-config.yaml

cd /home/ubuntu/environment/eks-kubeflow-cloudformation-quick-start/kubeflow-manifests
make port-forward
