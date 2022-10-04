## Deleting the AWS resources

Run below commands in Cloud9 to delete AWS resources.

```shell
cd /home/ubuntu/environment/eks-kubeflow-cloudformation-quick-start/kubeflow-manifests/deployments/vanilla/terraform
make delete
aws iam delete-role --role-name sagemakerrole
```
