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

2) The Cloudformation will run for about 20-25 minutes and will

  * Setup a Linux Jump Box with eksctl and kubectl.
  * Deploy EKS, KubeFlow and Sagemaker operators for k8s.
  * Deploy Cloud9.

You can watch the installation process by logging into the jump server (using EC2 instance connect) and tailing the log file at /var/log/cloud-init-output.log. Go to Cloudformation service in AWS Console and check the stack which you just created-

![Image2](/images/Image2.png)

Go to resources tab in the CF-

![Image3](/images/Image3.png)

Select the WebServerInstance to go to the Linux Jump Box in EC2 console and select Connect.

![Cloud9-9.png](/images/Cloud9-9.png)

Select "Session Manager" and then click on "Connect". This will open SSH shell in browser.

![Cloud9-6](/images/Cloud9-6.png)

Once connected to the Jump Box you can watch the installation of EKS, KubeFlow, Sagemaker operators and Cloud9 at /var/log/cloud-init-output.log

![Cloud9-7](/images/Cloud9-7.png)

![Cloud9-8](/images/Cloud9-8.png)

Wait for the installation to complete (should take approx 20-25 minutes). You will see below message at the end of bootstrapping.

![Cloud-Init-Finish](/images/Cloud-Init-Finish.png)

3) Connect to the Linux Jump Box from Cloud9 for accessing Kubeflow dashboard.

Open Cloud9 Console and create a new environment.

![Create-Cloud-9](/images/Create-Cloud-9.png)

Give Name and Description-

![Cloud9-Screenshot2](/images/Cloud9-Screenshot2.png)

In next screen choose, "Connect and run in remote server" and Enter Public DNS of the Linux Jump Server and Port as 22.

![Cloud9-Screenshot3](/images/Cloud9-Screenshot3.png)

Before moving to next screen, we need to copy the Cloud9 public SSH key into our Linux jump server. Click on "Copy Key to Clipboard"
and go SSH console of Linux Jump Server and update the file at /home/ec2-user/.ssh/authorized_keys.

![LinuxServer1](/images/LinuxServer1.png)

![LinuxServer2](/images/LinuxServer2.png)

![LinuxServer3](/images/LinuxServer3.png)

Once the SSH key is copied to authorized_keys file, go back to the Cloud9 screen and complete creating the environment.

You should see Cloud9 console in a few moments.

![Cloud9-1](/images/Cloud9-1.png)

On Cloud9, open a new terminal and run command-

```shell
kubectl get ingress -n istio-system
```

You can use the ingress URL to authenticate and login to Kubeflow.


### Deletion/Roll-Back steps-

1) eksctl delete cluster
2) Delete IAM OIDC
3) Delete IAM Roles.
4) Delete/Disable the AWS KMS Custom Key (optional)
5) Delete the Cloudformation templates . There will be total three templates ( 2 from eksctl and 1 which you created at the beginning of the lab).

### Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

### License

This library is licensed under the MIT-0 License. See the LICENSE file.
