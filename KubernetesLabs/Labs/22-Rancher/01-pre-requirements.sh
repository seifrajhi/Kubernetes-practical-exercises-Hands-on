#!/bin/bash

### Install k3 & other tools on MacOS
# brew install k3d kubectl helm

# In case you are not using mac - 
curl -sfL https://get.k3s.io | sh -

# Install cmctl
# cmctl is a CLI tool that can help you to manage cert-manager resources inside your cluster.
# https://cert-manager.io/docs/usage/cmctl/
OS=$(go env GOOS); 
ARCH=$(go env GOARCH); 

## create forlder for the installation
mkdir -p cmctl
cd cmctl
## Download cmctl 
### -> cmctl is a CLI tool that can help you to manage cert-manager resources inside your cluster.
curl -sSL -o cmctl.tar.gz https://github.com/cert-manager/cert-manager/releases/download/v1.8.0/cmctl-$OS-$ARCH.tar.gz
# Extract the xzip file
tar xzf cmctl.tar.gz
# Add it to the path 
sudo mv cmctl /usr/local/bin

# Delete the installtion fodler
cd ..
rm -rf cmctl

### Install k3s - Will be used later on for Rancher
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash

### Add the required helm charts
helm repo add rancher   https://releases.rancher.com/server-charts/latest
helm repo add jetstack  https://charts.jetstack.io

# Update the charts repository
helm repo update
