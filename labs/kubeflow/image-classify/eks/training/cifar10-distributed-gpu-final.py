import argparse
import json
import logging
import os
import sys
import boto3


import torch
import torch.distributed as dist
import torch.nn as nn
import torch.nn.functional as F
import torch.optim as optim
import torch.utils.data
import torch.utils.data.distributed
import torchvision
from torchvision import datasets, transforms
import json
#import subprocess

logger = logging.getLogger(__name__)
logger.setLevel(logging.DEBUG)
logger.addHandler(logging.StreamHandler(sys.stdout))

# Define models
class Net(nn.Module):
    def __init__(self):
        super(Net, self).__init__()
        self.conv1 = nn.Conv2d(3, 6, 5)
        self.pool = nn.MaxPool2d(2, 2)
        self.conv2 = nn.Conv2d(6, 16, 5)
        self.fc1 = nn.Linear(16 * 5 * 5, 120)
        self.fc2 = nn.Linear(120, 84)
        self.fc3 = nn.Linear(84, 10)

    def forward(self, x):
        x = self.pool(F.relu(self.conv1(x)))
        x = self.pool(F.relu(self.conv2(x)))
        x = x.view(-1, 16 * 5 * 5)
        x = F.relu(self.fc1(x))
        x = F.relu(self.fc2(x))
        x = self.fc3(x)
        return x

# Define data augmentation
def _get_transforms():
        transform = transforms.Compose([
        transforms.RandomCrop(32, padding=4),
        transforms.RandomHorizontalFlip(),
        transforms.ToTensor(),
        transforms.Normalize((0.4914, 0.4822, 0.4465), (0.2023, 0.1994, 0.2010)),
    ])
        return transform

# Define data loader for training dataset
def _get_train_data_loader(batch_size, training_dir, is_distributed):
    logger.info("Get train data loader")
   
    train_set = torchvision.datasets.CIFAR10(root=training_dir, 
                                             train=True, 
                                             download=False, 
                                             transform=_get_transforms()) 
    
    train_sampler = (
        torch.utils.data.distributed.DistributedSampler(train_set) if is_distributed else None
    )
    
    return torch.utils.data.DataLoader(
        train_set,
        batch_size=batch_size,
        shuffle=train_sampler is None,
        sampler=train_sampler)

# Define data loader for test dataset
def _get_test_data_loader(test_batch_size, training_dir):
    logger.info("Get test data loader")
    
    test_set = torchvision.datasets.CIFAR10(root=training_dir, 
                                            train=False, 
                                            download=False, 
                                            transform=_get_transforms())
    
    return torch.utils.data.DataLoader(
        test_set,
        batch_size=test_batch_size,
        shuffle=True)

# Average gradients (only for multi-node CPU)
def _average_gradients(model):
    # Gradient averaging.
    size = float(dist.get_world_size())
    for param in model.parameters():
        dist.all_reduce(param.grad.data, op=dist.reduce_op.SUM)
        param.grad.data /= size

# Define training loop
def train(args):
    world_size = int(os.environ.get("WORLD_SIZE", 1)) if "SM_HOSTS" not in os.environ else len(args.hosts)

    is_distributed = (world_size > 1) and args.backend is not None
    logger.info("Distributed training - {}".format(is_distributed))
    logger.info("world_size - {}".format(world_size))
    
    device = "cuda" if torch.cuda.is_available() else "cpu"

    if is_distributed:
        logger.info("args.hosts - {}".format(world_size))
        
        host_rank = int(os.environ.get("RANK", 1)) if "SM_HOSTS" not in os.environ else args.hosts.index(args.current_host)
        logger.info("args.current_host - {}".format(host_rank))
        
        dist.init_process_group(backend=args.backend, rank=host_rank, world_size=world_size)
        
        logger.info(
            "Initialized the distributed environment: '{}' backend on {} nodes. ".format(
                args.backend, dist.get_world_size()
            ))

    # Set the seed for generating random numbers
    torch.manual_seed(args.seed)
    
    data_dir = ("/" + args.efs_mount_path + "/" + args.efs_dir_path) if "SM_CHANNEL_TRAIN" not in os.environ else args.data_dir
    
    logger.info("data dir path - {}".format(data_dir))

    train_loader = _get_train_data_loader(args.batch_size,     data_dir, is_distributed)
    test_loader  = _get_test_data_loader(args.test_batch_size, data_dir)

    logger.debug(
        "Processes {}/{} ({:.0f}%) of train data".format(
            len(train_loader.sampler),
            len(train_loader.dataset),
            100.0 * len(train_loader.sampler) / len(train_loader.dataset),
        )
    )

    logger.debug(
        "Processes {}/{} ({:.0f}%) of test data".format(
            len(test_loader.sampler),
            len(test_loader.dataset),
            100.0 * len(test_loader.sampler) / len(test_loader.dataset),
        )
    )
      
    model = Net().to(device)
    
    if is_distributed:
        model = torch.nn.parallel.DistributedDataParallel(model)

    criterion = nn.CrossEntropyLoss().to(device)
    optimizer = optim.SGD(model.parameters(), lr=args.lr, momentum=args.momentum)

    running_loss=0.0
    running_correct=0
    n_total_steps=len(train_loader)
    
  
    for epoch in range(1, args.epochs + 1):
        model.train()
        for batch_idx, (data, target) in enumerate(train_loader, 1):

            data, target = data.to(device), target.to(device)
            
            #mycode
            grid=torchvision.utils.make_grid(data)
            
            optimizer.zero_grad()
            output = model(data)
            loss = criterion(output, target)
            loss.backward()
            if is_distributed and not torch.cuda.is_available():
                _average_gradients(model)
            optimizer.step()
            
            running_loss += loss.item()
            pred = output.max(1, keepdim=True)[1]
            running_correct += pred.eq(target.view_as(pred)).sum().item()
            
            if batch_idx % args.log_interval == 0:
                logger.info(
                    "Train Epoch: {} [{}/{} ({:.0f}%)] Loss: {:.6f}".format(
                        epoch,
                        batch_idx * len(data),
                        len(train_loader.sampler),
                        100.0 * batch_idx / len(train_loader),
                        loss.item(),
                    )
                )
                
                running_loss=0.0
                running_correct=0
                
        test(model, test_loader, device) 
    
    logger.info('Saving trained model only on rank 0')
    rank = os.getenv('RANK')
    if rank is not None:
        if int(rank) == 0:
            save_model(model, args.model_dir)
    else:
        save_model(model, args.model_dir)

def test(model, test_loader, device):
    model.eval()
    test_loss = 0
    correct = 0
    with torch.no_grad():
        for data, target in test_loader:
            data, target = data.to(device), target.to(device)
            output = model(data)
            test_loss += F.nll_loss(output, target, size_average=False).item()  # sum up batch loss
            pred = output.max(1, keepdim=True)[1]  # get the index of the max log-probability
            correct += pred.eq(target.view_as(pred)).sum().item()

    test_loss /= len(test_loader.dataset)
    logger.info(
        "Test set: Average loss: {:.4f}, Accuracy: {:.2f}\n".format(
            test_loss, correct / len(test_loader.dataset)
        )
    )
    
# We have saved the model using nn.DataParallel, which stores the model in module, and we wont be able to load it without DataParallel. So below we create a new ordered dict without the module prefix, and load it back.
def remove_ddp_model(model_dir, new_model_name):
    from collections import OrderedDict
    
    path = os.path.join(model_dir, "model.pth")
    
    logger.info("Path of current model: - {}".format(path))
    
    model = Net()
    # Original saved file with DataParallel
    checkpoint = torch.load(path,map_location=lambda storage, loc: storage)

    new_state_dict = OrderedDict()
    for k, v in checkpoint.items():
        name = k[7:] # remove `module.`
        new_state_dict[name] = v

    # Load parameters
    model.load_state_dict(new_state_dict)
    
    path = os.path.join(model_dir, new_model_name)
    
    logger.info("Path of new model after removing ddp module: - {}".format(path))

    torch.save(new_state_dict, path)
    
    return path

def save_model(model, model_dir):
    logger.info("Saving the model.")
    #isExist = os.path.exists(model_dir)
    #logger.info("model_dir exists ? - {}".format(isExist))
    
    if "SM_CHANNEL_TRAIN" not in os.environ:
        model_dir="/"+args.efs_mount_path
        path = os.path.join(model_dir, "model.pth")

        #os.makedirs(model_dir)
        logger.info("The new directory is: - {}".format(model_dir))
        
        torch.save(model.cpu().state_dict(), path)
        
        updated_path=remove_ddp_model(model_dir, "model_kserve.pth")
        
        logger.info("Updated Path of new model after removing ddp module: - {}".format(path))
        
        s3 = boto3.resource(service_name = 's3')
        logger.info("S3 bucket: - {}".format(args.s3bucket))
        s3.meta.client.upload_file(Filename = updated_path, Bucket = args.s3bucket, Key = 'model-kserve.pth')
        
    else:
        path = os.path.join(model_dir, "model.pth")
        logger.info("model save path - {}".format(path))

        torch.save(model.cpu().state_dict(), path)

if __name__ == "__main__":
    logger.info("Starting the script.")
    parser = argparse.ArgumentParser()

    # PyTorch environments
    parser.add_argument("--model-type",type=str,default='resnet18',
                        help="custom model or resnet18")
    parser.add_argument("--batch-size",type=int,default=64,
                        help="input batch size for training (default: 64)")
    parser.add_argument("--test-batch-size",type=int,default=1000,
                        help="input batch size for testing (default: 1000)")
    parser.add_argument("--epochs",type=int,default=10,
                        help="number of epochs to train (default: 10)")
    parser.add_argument("--lr", type=float, default=0.01,
                        help="learning rate (default: 0.01)")
    parser.add_argument("--momentum", type=float, default=0.5,
                        help="SGD momentum (default: 0.5)")
    parser.add_argument("--seed", type=int, default=1,
                        help="random seed (default: 1)")
    parser.add_argument("--log-interval",type=int,default=10,
                        help="how many batches to wait before logging training status")
    parser.add_argument("--backend",type=str,default='gloo',
                        help="backend for dist. training, this script only supports gloo")
    
    parser.add_argument("--efs-mount-path",type=str,default="efs-sc-claim",
                        help="efs mount path")
    
    parser.add_argument("--efs-dir-path",type=str,default="cifar10-dataset",
                        help="efs mount path")
    
    parser.add_argument("--s3bucket",type=str,default="s3bucketname",
                        help="s3 bucket name")

    # SageMaker environment    
    parser.add_argument("--hosts", type=list, default=json.loads(os.environ.get("SM_HOSTS","{}")))
    parser.add_argument("--current-host", type=str, default=os.environ.get("SM_CURRENT_HOST","algo-1"))
    parser.add_argument("--data-dir", type=str, default=os.environ.get("SM_CHANNEL_TRAIN","/efs-sc-claim/cifar10-dataset"))
    parser.add_argument("--model-dir", type=str, default=os.environ.get("SM_MODEL_DIR", "/opt/ml/model"))
 
    args=parser.parse_args()
    
    train(args)
    
  