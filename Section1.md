## Section 1

Use below instructions to set up Kubeflow 1.6 running on EKS 1.22. The scripts are referenced from https://awslabs.github.io/kubeflow-manifests/main/docs/deployment/vanilla/guide-terraform/

### Instructions

Create a Cloud9 Environment.


![ScreenShot1](/images/a1.png)

Select Create Environment

![ScreenShot2](/images/a2.png)

Add details

![ScreenShot3](/images/a3.png)

For Instance type, you can select M5.Large. For Platform, select Ubuntu Server 18.04 LTS

![ScreenShot4](/images/a4.png)

Select Create Environment

![ScreenShot5](/images/a5.png)

![ScreenShot6](/images/a6.png)

![ScreenShot7](/images/a7.png)

Select "Share" on right corner

![ScreenShot8](/images/a8.png)

Under AWS SETTINGS, un-select "AWS Managed temporary credentials"

![ScreenShot9](/images/a9.png)

Go to AWS Management console, select EC2

![ScreenShot10](/images/a10.png)

Select the Cloud9 Instance in EC2 console, click on Actions --> Security --> Modify IAM Role

![ScreenShot11](/images/a11.png)

On next screen, select "Create new IAM Role"

![ScreenShot12](/images/a12.png)

Hit Create Role

![ScreenShot13](/images/a13.png)

Select AWS Service and EC2

![ScreenShot14](/images/a14.png)

Look for Administrator on search bar at top and select "AdministratorAccess" policy name. 

![ScreenShot15](/images/a15.png)

Give Role Name and Description and create the role.

![ScreenShot16](/images/a16.png)


![ScreenShot17](/images/a17.png)

Go back to the previous screen and select the role which we created and select "Update IAM role"

![ScreenShot18](/images/a18.png)

On Cloud9 terminal, we can test our permissions

```shell
aws sts get-caller-identity
```

![ScreenShot19](/images/a19.png)

Clone the git repo. 

```shell
git clone https://github.com/kalawat1985/eks-kubeflow-cloudformation-quick-start.git
```

![ScreenShot20](/images/a20.png)

Access terraform folder by running below command. 

```shell
cd eks-kubeflow-cloudformation-quick-start
```

![ScreenShot21](/images/a21.png)

Run scriptv1.sh

```shell
./scriptv1.sh
```

Scriptv1.sh will run for about 20-25 minutes and will setup EKS, Kubeflow in our AWS account using Terraform.


### Accessing Kubeflow Dashboard

You can run Kubeflow dashboard locally in Cloud9 environment without exposing your URLs to public Internet.

From Terraform folder, run

```shell
$(terraform output -raw configure_kubectl)
```
![ScreenShot22](/images/a22.png)

From kubeflow manifest folder, run

```shell
make port-forward
```


![ScreenShot23](/images/a23.png)


Select "Preview Running Application"

![ScreenShot24](/images/a24.png)

Kubeflow Dashboard

![ScreenShot25](/images/a25.png)

