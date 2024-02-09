#!/bin/bash

KIND_VERSION=${1:-"0.5.1"}
curl -sLo kind https://github.com/kubernetes-sigs/kind/releases/download/v${KIND_VERSION}/kind-$(uname)-amd64 
chmod +x kind
sudo mv kind /usr/local/bin/
