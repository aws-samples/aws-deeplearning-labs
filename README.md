## EKS Kubeflow Quickstart (Update 12/13/2021)

- [x] Update KubeFlow to 1.2 running on EKS 1.18 :rocket:
- [x] Fix Sagemaker Operators Install issues for regions other than us-east-2. :rocket:

### Why?

For people who wish to start using KubeFlow and Sagemaker operators for Kubernetes without spending any time on installation of underlying infrastructure and tools can use the CloudFormation in this git repo. The scripts in this git repo are referenced from -

  - https://eksworkshop.com/ 
  - https://sagemaker.readthedocs.io/en/stable/amazon_sagemaker_operators_for_kubernetes.html. 

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

From AWS Console, open Systems Manager.

![Paramter-Store-1](/images/Parameter-Store-1.png)

Select Parameter Store

![Paramter-Store-2](/images/Parameter-Store-2.png)

We can see the Cloudformation has created three parameters in the parameter store.

![Paramter-Store-3](/images/Parameter-Store-3.png)

You can check for value of each parameter by selecting respective entry. For example below screenshot shows the value of ISTIO_URL.

![Paramter-Store-4](/images/Parameter-Store-4.png)


#### Take a note of the Value of ISTIO_URL, ISTIO_PASS and ISTIO_USER. 

Open ISTIO_URL in a new browser window on your workstation. For userid and password use the values of ISTIO_USER and ISTIO_PASS.

![accessing-eks-ingress-kubeflow-browser](/images/accessing-eks-ingress-kubeflow-browser.png)

Accessing the Kubeflow dashboard.

![kubeflow-screenshot-1](/images/kubeflow-screenshot-1.png)

![kubeflow-screenshot-2](/images/kubeflow-screenshot-2.png)


## Deleting the AWS resources

1) eksctl delete cluster
2) Delete IAM OIDC
3) Delete IAM Roles.
4) Delete/Disable the AWS KMS Custom Key (optional)
5) Delete the Cloudformation templates . There will be total three templates ( 2 from eksctl and 1 which you created at the beginning of the lab).
6) Delete any AWS resources manually if Cloudformation template is not able to remove them.

### Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

### License

This library is licensed under the MIT-0 License. See the LICENSE file.
