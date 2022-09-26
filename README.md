## EKS Kubeflow Quickstart (Update 09/26/2022)

Use this git repo to set up Kubeflow 1.6 running on EKS 1.22. The scripts in this git repo are referenced fromhttps://awslabs.github.io/kubeflow-manifests/main/docs/deployment/vanilla/guide-terraform/

### Instructions

1) Clone the git repo locally on your workstation and execute the Cloudformation template (we assume that you have already setup awscli)

```shell
aws cloudformation create-stack --stack-name myteststack --template-body file://cfv1.json --capabilities CAPABILITY_IAM
```

![ScreenShot1](/images/ScreenShot1.png)

2) The Cloudformation will perform below tasks

  * Setup a Ubuntu Linux Jump Box.
  * Deploy EKS 1.22, KubeFlow 1.6, SageMaker ACKs
  * Deploy Cloud9.

### Accessing Kubeflow Dashboard

  * You can run Kubeflow dashboard locally in Cloud9 environment without exposing your URLs to public Internet.  

## Deleting the AWS resources

```shell
make delete
```

### Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

### License

This library is licensed under the MIT-0 License. See the LICENSE file.
