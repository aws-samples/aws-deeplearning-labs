## Installation of KubeFlow, EKS using Terraform

Make sure you are in us-west-2 region (Oregon). Create a Cloud9 Environment.

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

Click "Settings icon"

![ScreenShot8](/images/a31.png)

Scroll down the list on left and click AWS SETTINGS, un-select "AWS Managed temporary credentials

![ScreenShot9](/images/a9.png)

Go to AWS Management console, select EC2.
You can click T icon on top left and click Manage EC2 Instance

![ScreenShot10](/images/a30.png)

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

Go back to the previous screen and select the role which we created and select "Update IAM role". Refresh the drop down using refresh button next to drop down if you don't see the role you created

![ScreenShot18](/images/a18.png)

From your Cloud9 environment, click on "+" icon and open new terminal. On Cloud9 terminal, we can test our permissions

```shell
aws sts get-caller-identity
```

![ScreenShot19](/images/a19.png)

Clone the git repo. 

```shell
git clone https://github.com/aws-samples/eks-kubeflow-cloudformation-quick-start.git
```

![ScreenShot20](/images/a20.png)

```shell
cd eks-kubeflow-cloudformation-quick-start
```

Run install_eks_kubeflow.sh

```shell
./install_eks_kubeflow.sh
```

install_eks_kubeflow.sh will run for about 30-35 minutes and will setup EKS, Kubeflow in our AWS account using Terraform.


### Accessing Kubeflow Dashboard

You can run Kubeflow dashboard locally in Cloud9 environment without exposing your URLs to public Internet. Run -

```shell
./kubeflow_dashboard.sh
```

![ScreenShot26](/images/a26.png)


Select "Preview Running Application". Enter the default credentials (user@example.com / 12341234) to log in to Kubeflow.

![ScreenShot24](/images/a24.png)

Kubeflow Dashboard

![ScreenShot25](/images/a25.png)

