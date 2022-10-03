# Distributed Training using PyTorch with Kubeflow on AWS and Amazon SageMaker

Welcome! By completing this workshop you will learn how to run distributed data parallel model training on Amazon SageMaker(https://aws.amazon.com/sagemaker/) using [PyTorch](https://pytorch.org) and Kubeflow on AWS (an AWS-specific distribution of Kubeflow).

The only prerequisite for this workshop is access to an AWS account. The steps included in this workshop will walk you through accessing AWS account, creating and deploying AWS EKS cluster and Kubeflow on AWS using Terraform scripts and running distributed training of an image classification model using PyTorch DDP on Amazon SageMaker through Kubeflow on AWS Pipeline integration. 

The workshop architecture at a high level can be visualized by the diagram below.

![image](/images/a27.png)

The workshop is designed to introduce the concepts of deploying this architecture and running small-scale distributed training for educational purposes, however the same architecture can be applied for training at large scale by adjusting the number and type of nodes used in the Amazon SageMaker cluster, using accelerators ([NVIDIA GPUs](https://aws.amazon.com/nvidia/), [AWS Trainium](https://aws.amazon.com/machine-learning/trainium/), and high-performance shared storage like [FSx for Lustre](https://aws.amazon.com/fsx/lustre/).

# How does Kubeflow on AWS and SageMaker help?

Neural network models built with deep learning frameworks like TensorFlow, PyTorch, MXNet, and others provide much higher accuracy by using significantly larger training datasets, especially in computer vision and natural language processing use cases. However, with large training datasets, it takes longer to train the deep learning models, which ultimately slows down the time to market. If we could scale out a cluster and bring down the model training time from weeks to days or hours, it could have a huge impact on productivity and business velocity.

Amazon EKS helps provision the managed Kubernetes control plane. You can use Amazon EKS to create large-scale training clusters with CPU and GPU instances and use the Kubeflow toolkit to provide ML-friendly, open-source tools and operationalize ML workflows that are portable and scalable using Kubeflow Pipelines to improve your team’s productivity and reduce the time to market.

However, there could be a couple of challenges with this approach:

1. Ensuring maximum utilization of a cluster across data science teams. For example, you should provision GPU instances on demand and ensure its high utilization for demanding production-scale tasks such as deep learning training, and use CPU instances for the less demanding tasks such data preprocessing

2. Ensuring high availability of heavyweight Kubeflow infrastructure components, including database, storage, and authentication, that are deployed in the Kubernetes cluster worker node. For example, the Kubeflow control plane generates artifacts (such as MySQL instances, pod logs, or MinIO storage) that grow over time and need resizable storage volumes with continuous monitoring capabilities.

3. Sharing the training dataset, code, and compute environments between developers, training clusters, and projects is challenging. For example, if you’re working on your own set of libraries and those libraries have strong interdependencies, it gets really hard to share and run the same piece of code between data scientists in the same team. Also, each training run requires you to download the training dataset and build the training image with new code changes.
Kubeflow on AWS helps address these challenges and provides an enterprise-grade semi-managed Kubeflow product. With Kubeflow on AWS, you can replace some Kubeflow control plane services like database, storage, monitoring, and user management with AWS managed services like Amazon Relational Database Service (Amazon RDS), Amazon Simple Storage Service (Amazon S3), Amazon Elastic File System (Amazon EFS), Amazon FSx, Amazon CloudWatch, and Amazon Cognito.

Replacing these Kubeflow components decouples critical parts of the Kubeflow control plane from Kubernetes, providing a secure, scalable, resilient, and cost-optimized design. This approach also frees up storage and compute resources from the EKS data plane, which may be needed by applications such as distributed model training or user notebook servers. Kubeflow on AWS also provides native integration of Jupyter notebooks with Deep Learning Container (DLC) images, which are pre-packaged and preconfigured with AWS optimized deep learning frameworks such as PyTorch and TensorFlow that allow you to start writing your training code right away without dealing with dependency resolutions and framework optimizations. Also, Amazon EFS integration with training clusters and the development environment allows you to share your code and processed training dataset, which avoids building the container image and loading huge datasets after every code change. These integrations with Kubeflow on AWS help you speed up the model building and training time and allow for better collaboration with easier data and code sharing.

Kubeflow on AWS helps build a highly available and robust ML platform. This platform provides flexibility to build and train deep learning models and provides access to many open-source toolkits, insights into logs, and interactive debugging for experimentation. However, achieving maximum utilization of infrastructure resources while training deep learning models on hundreds of GPUs still involves a lot of operational overheads. This could be addressed by using SageMaker, which is a fully managed service designed and optimized for handling performant and cost-optimized training clusters that are only provisioned when requested, scaled as needed, and shut down automatically when jobs complete, thereby providing close to 100% resource utilization. You can integrate SageMaker with Kubeflow Pipelines using managed SageMaker components. This allows you to operationalize ML workflows as part of Kubeflow pipelines, where you can use Kubernetes for local training and SageMaker for product-scale training in a hybrid architecture.

# WorkShop Steps

This workshop is organized in a number of sequential steps. Steps 1 through 3 are required to complete the workshop.

## 1. Login to AWS Account ([0_AWS_LOGIN.md](0_AWS_LOGIN.md))
1 If you are running the workshop on your own and you don’t already have an AWS account with Administrator access, please create one now by clicking here (https://aws.amazon.com/getting-started/).

2 If you are running the workshop at an AWS Event or with AWS teams, please follow the instructions in [0_AWS_LOGIN.md](0_AWS_LOGIN.md).

## 2. Setup Amazon EKS and Kubeflow on AWS ([1_INSTALL.md](1_INSTALL.md))
Before we get started, we need to set up an AWS account and Cloud9 IDE from which we will execute all the steps in the workshop. You will not be required to install anything on your computer. All of the steps in the workshop will be completed on the cloud through your browser. To set up your account and IDE, please follow the instructions in [1_INSTALL.md](1_INSTALL.md).

## 3 Run the use case examples ([2_USE_CASE.md](2_USE_CASE.md))
Set up the Jupyter notebook and run the entire demo by following the instructions in ([2_USE_CASE.md](2_USE_CASE.md))
