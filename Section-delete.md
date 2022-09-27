## Section 1

Use below instructions to set up Kubeflow 1.6 running on EKS 1.22. The scripts are referenced from https://awslabs.github.io/kubeflow-manifests/main/docs/deployment/vanilla/guide-terraform/

### Instructions

Create a Cloud9 Environment.


![ScreenShot1](/images/a1.png)

![ScreenShot2](/images/a2.png)

![ScreenShot3](/images/a3.png)

![ScreenShot4](/images/a4.png)

![ScreenShot5](/images/a5.png)

![ScreenShot6](/images/a6.png)

![ScreenShot7](/images/a7.png)

![ScreenShot8](/images/a8.png)

![ScreenShot9](/images/a9.png)

![ScreenShot10](/images/a10.png)

![ScreenShot11](/images/a11.png)

![ScreenShot12](/images/a12.png)

![ScreenShot13](/images/a13.png)

![ScreenShot14](/images/a14.png)

![ScreenShot15](/images/a15.png)

![ScreenShot16](/images/a16.png)

![ScreenShot17](/images/a17.png)

![ScreenShot18](/images/a18.png)

![ScreenShot19](/images/a19.png)

![ScreenShot20](/images/a20.png)

![ScreenShot21](/images/a21.png)

Run make deploy from Terraform folder.

```shell
make deploy
```

### Accessing Kubeflow Dashboard

You can run Kubeflow dashboard locally in Cloud9 environment without exposing your URLs to public Internet.

From Terraform folder, run

```shell
$(terraform output -raw configure_kubectl)
```

From kubeflow manifest folder, run

```shell
make port-forward
```

![ScreenShot22](/images/a22.png)

![ScreenShot23](/images/a23.png)

![ScreenShot24](/images/a24.png)

![ScreenShot25](/images/a25.png)


## Deleting the AWS resources


```shell
cd /home/ubuntu/environment/eks-kubeflow-cloudformation-quick-start/kubeflow-manifests/deployments/vanilla/terraform
make delete
```
