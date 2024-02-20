# 🚦 Deploying Kubernetes

Deploying a Kubernetes can be extremely complex, with many networking, compute and other aspects to consider.
However for the purposes of this workshop, a default and basic K3s cluster can be deployed very quickly.

## 🚀 Virtual Machine Deployment

Use the following commands to create a VM and a resource group:

```bash
# Create Azure resource group
az group create --name $RES_GROUP --location $REGION

# Create cluster
az vm create \
    --resource-group $RES_GROUP \
    --name $VM_NAME \
    --image UbuntuLTS \
    --public-ip-sku Standard \
    --size Standard_D2s_v3 \
    --admin-username azureuser \
    --generate-ssh-keys

# Open two additional ports on the VM, that'll be used later
az network nsg rule create --resource-group $RES_GROUP --nsg-name ${VM_NAME}NSG  --name AllowNodePorts --protocol tcp --priority 1001 --destination-port-ranges 30036 30037

```

Save the VMs public IP and SSH key files for use in the next steps

## 🌐Connect to the VM from VSCode

To make creating files easier on the machine it's recommended to use [VS Code](https://code.visualstudio.com/) Remote extension with SSH to connect to the VM.
See the documentation [here](https://code.visualstudio.com/docs/remote/ssh) for more on developing on Remote Machines using SSH and Visual Studio Code.

It's also highly recommended to get the [Kubernetes extension](https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools).

## 🤘 Set up K3s cluster

Run all of these commands inside of your VM.

First, let's install the K3S cluster and tools in the VM:

```sh
# Install kubectl
sudo apt-get update
sudo apt-get install -y apt-transport-https ca-certificates curl
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list
sudo apt-get update
sudo apt-get install -y kubectl

# Install K3S
curl -sfL https://get.k3s.io | sh -

# Install helm
curl -s https://raw.githubusercontent.com/benc-uk/tools-install/master/helm.sh | bash

# Optionally install Azure CLI
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash

```

> 📝 NOTE: Login into the Azure CLI if you've installed it.

Let's connect your kubectl with k3s and allow your user permissions to access the cluster.

```sh
echo "export KUBECONFIG=/etc/rancher/k3s/k3s.yaml" >> ~/.bashrc
sudo chown azureuser /etc/rancher/k3s/k3s.yaml
sudo chown azureuser /etc/rancher/k3s
```

Then let's set up the VM user profile for K3s to make it easier to run all the commands:

```sh
echo "source <(kubectl completion bash)" >> ~/.bashrc
echo "alias k=kubectl" >> ~/.bashrc
echo "complete -o default -F __start_kubectl k" >> ~/.bashrc
echo "export PATH=$PATH:/home/azureuser/.local/bin" >> ~/.bashrc
```

Double check that everything in installed and working correctly with:

```sh
# For bashrc changes to take affect in your current terminal, you must reload bashrc with:
. ~/.bashrc
# Try commands
k get pods -A
helm
```

## ⏯️ Appendix - Stopping & Starting the VM

If you are concerned about the costs for running the VM you can stop and start it at any time.

```bash
# Stop the VM
az vm stop --resource-group $RES_GROUP --name $AKS_NAME

# Start the VM
az vm start --resource-group $RES_GROUP --name $AKS_NAME
```

> 📝 NOTE: Start and stop operations do take several minutes to complete, so typically you would perform
> them only at the start or end of the day.

## Navigation

[Return to Main Index 🏠](../../readme.md)
[Previous Section ⏪](../00-pre-reqs/readme.md) ‖ [Next Section ⏩](../02-container-registry/readme.md)
