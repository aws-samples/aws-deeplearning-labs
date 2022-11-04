from __future__ import print_function

import os
import torch
import torch.nn as nn 
import torch.nn.functional as F
import io

import io, os, sys
import json

import numpy as np
from base64 import b64decode
from PIL import Image

import torch
import torchvision
from torchvision import datasets, transforms, models
from torchvision.models.detection import FasterRCNN
import torchvision.transforms as transforms

# Model Network definition
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

# Load the model  
def model_fn(model_dir):
    device = "cpu"
    model = Net()
    
    with open(os.path.join(model_dir, "model.pth"), "rb") as f:
        model.load_state_dict(torch.load(f, map_location=device))
    return model.to(device)


# Deserialize the image in request body and predicts on the deserialized object with the model from model_fn()
def transform_fn(model, request_body, content_type='application/x-image', accept_type=None):
    device = "cpu"
    
    img = np.array(Image.open(io.BytesIO(request_body)))
    
    test_transforms = transforms.Compose([
        transforms.ToTensor()
    ])
    
    img_tensor = test_transforms(img).to(device)
    img_tensor = img_tensor.unsqueeze(0)
            
    with torch.no_grad():    
        outputs = model(img_tensor)
        
    max=torch.max(outputs)
        
    result = np.where(outputs == max.item())
    
    outputs_final = json.dumps({'score': outputs.tolist()})
    
    return outputs_final
