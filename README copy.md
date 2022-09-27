## Kubeflow Setup Instructions (Update 09/26/2022)

Use below instructions to set up Kubeflow 1.6 running on EKS 1.22. The scripts are referenced from https://awslabs.github.io/kubeflow-manifests/main/docs/deployment/vanilla/guide-terraform/

### Instructions




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


## Deleting the AWS resources

```shell
make delete
```

### Security

See [CONTRIBUTING](CONTRIBUTING.md#security-issue-notifications) for more information.

### License

This library is licensed under the MIT-0 License. See the LICENSE file.
