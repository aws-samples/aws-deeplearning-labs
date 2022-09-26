## EKS Kubeflow Quickstart (Update 09/26/2022)

For people who wish to start using KubeFlow and Sagemaker operators for Kubernetes without spending any time on installation of underlying infrastructure and tools can use the CloudFormation in this git repo. The scripts in this git repo are referenced from -

  - https://eksworkshop.com/ 
  - https://awslabs.github.io/kubeflow-manifests/main/docs/deployment/vanilla/guide-terraform/

### Instructions

1) Clone the git repo locally on your workstation and execute the Cloudformation template (we assume that you have already setup awscli)

```shell
aws cloudformation create-stack --stack-name myteststack --template-body file://cfv1.json --capabilities CAPABILITY_IAM
```

![ScreenShot1](/images/ScreenShot1.png)

2) The Cloudformation will perform below tasks

  * Setup a Linux Jump Box with eksctl and kubectl.
  * Deploy EKS, KubeFlow and Sagemaker operators for k8s.
  * Deploy Cloud9.
  * Copy the Kubeflow URL, userid and password to System Manager parameter store.


### Accessing Kubeflow Dashboard





## Deleting the AWS resources



### Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

### License

This library is licensed under the MIT-0 License. See the LICENSE file.
