## Deleting the AWS resources

Run below commands in Cloud9 to delete AWS resources.

```shell
cd /home/ubuntu/environment/aws-deeplearning-labs/kubeflow-manifests/deployments/vanilla/terraform
make delete
```

Delete IAM role sagemakerrole manually from AWS Console.

Remove hard-coded environment variables in .bash_profile at /home/ubuntu/.bash_profile

AWS_CLUSTER_NAME
AWS_REGION
NODE_IAM_ROLE

