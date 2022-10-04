#!/bin/bash
# Setup Cloud9 on our Jump Server

#Install Node.Js for Root
curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash
source ~/.nvm/nvm.sh
source ~/.bashrc
nvm install node

#Install Node.JS for ec2-user
/bin/su -c "curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.34.0/install.sh | bash" - ubuntu
/bin/su -c "source ~/.nvm/nvm.sh" - ubuntu
/bin/su -c "source ~/.bashrc" - ubuntu
/bin/su -c "nvm install node" - ubuntu

#Install Dev Tools
sudo apt update

# Install Cloud9 with Ec2-user

sudo /bin/su -c "curl -L https://raw.githubusercontent.com/c9/install/master/install.sh | bash" - ubuntu
sudo /bin/su -c "wget -O - https://raw.githubusercontent.com/c9/install/master/install.sh | bash" - ubuntu