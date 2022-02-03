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

Go to Cloudformation service in AWS Console and check the stack which you just created-

![Image2](/images/Image2.png)

Go to resources tab in the Cloudformation

![Image3](/images/Image3.png)

Select the WebServerInstance to go to the Linux Jump Box in EC2 console and select Connect.

![Cloud9-9.png](/images/Cloud9-9.png)

Select "Session Manager" and then click on "Connect". This will open SSH shell in browser.

![Cloud9-6](/images/Cloud9-6.png)

Watch the installation process by running following commands.

```
sudo su - 
cd /var/log
tail -f cloud-init-output.log
```

![Cloud9-7](/images/Cloud9-7.png)

![Cloud9-8](/images/Cloud9-8.png)

Wait for the installation to complete (should take approx. 30-35 minutes). You will see below message after all the scripts have executed.

![session-manager-cloud-init](/images/session-manager-cloud-init.png)


## Accessing EKS and Kubeflow from Session Manager.

You can check status of your EKS cluster, SageMaker operators and KubeFlow dashboard from the "Session Manager" console. Switch to ec2-user and run below commands and see their respective outputs.

```
sudo su - ec2-user
kubectl -n sagemaker-k8s-operator-system get pods
```

![session-manager-sm-operators](/images/session-manager-sm-operators.png)

```
kubectl get nodes
```

![session-manager-eks-nodes](/images/session-manager-eks-nodes.png)

```
kubectl get pods -n kubeflow
```

![session-manager-eks-kubeflow-pods](/images/session-manager-eks-kubeflow-pods.png)

```
kubectl get ingress -n istio-system
```

![session-manager-eks-ingress-kubeflow](/images/session-manager-eks-ingress-kubeflow.png)

Copy the URL under address open it on browser on your workstation.

#### For the purposes of this demo, our installation uses default passwords as mentioned at https://v1-4-branch.kubeflow.org/docs/distributions/aws/deploy/install-kubeflow/#understanding-the-deployment-process. Please make sure you are changing the password for admin or create a new user.

![accessing-eks-ingress-kubeflow-browser](/images/accessing-eks-ingress-kubeflow-browser.png)

Accessing the Kubeflow dashboard.

![kubeflow-screenshot-1](/images/kubeflow-screenshot-1.png)

![kubeflow-screenshot-2](/images/kubeflow-screenshot-2.png)


## (Optional) Using Cloud9 for accessing EKS, SageMaker Operators and Kubeflow.

In case you wish to use AWS Cloud9 IDE to access your EKS cluster, follow below steps. 

Open Cloud9 Console and create a new environment.

![cloud9-setup-1](/images/cloud9-setup-1.png)

Give Name and Description-

![cloud9-setup-2](/images/cloud9-setup-2.png)

In next screen choose, "Connect and run in remote server" and Enter Public DNS of the Linux Jump Server and Port as 22.

![cloud9-setup-4](/images/cloud9-setup-4.png)

Before moving to next screen, we need to copy the Cloud9 public SSH key into our Linux jump server. Click on "Copy Key to Clipboard" and go SSH console of Linux Jump Server and update the file at /home/ec2-user/.ssh/authorized_keys.

![cloud9-setup-5](/images/cloud9-setup-5.png)

![cloud9-setup-6](/images/cloud9-setup-6.png)

Once the SSH key is copied to authorized_keys file, go back to the Cloud9 screen and complete creating the environment.

![cloud9-setup-7](/images/cloud9-setup-7.png)

You should see Cloud9 console in a few moments.

![cloud9-setup-7](/images/cloud9-setup-7.png)

![cloud9-setup-8](/images/cloud9-setup-8.png)

![cloud9-setup-9](/images/cloud9-setup-9.png)

![cloud9-setup-10](/images/cloud9-setup-10.png)

![cloud9-setup-11](/images/cloud9-setup-11.png)


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
