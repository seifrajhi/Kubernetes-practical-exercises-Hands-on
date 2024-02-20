# ⚒️ Workshop Pre Requisites

In this workshop you'll be creating a stand alone, single node K3s cluster on a VM.
This VM will be in essence a simulation of what it's like to setup and run a K3S cluster on your own physical device.
You'll also be interacting the cluster directly on the VM, as opposed to your local machine.
You'll be using your local machine to create the Azure resources however.

As this is a completely hands on workshop, you will need a few things before you can start:

- Access to an Azure Subscription where you can create resources.
- A good editor that you can SSH from, and [VS Code](https://code.visualstudio.com/) is strongly recommended
  - [Visual Studio Code Remote Development extension](https://code.visualstudio.com/docs/remote/remote-overview)
  - [Kubernetes extension](https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools) also highly recommended
- [Azure CLI](https://aka.ms/azure-cli)

## 🌩️ Install Azure CLI

To set-up the Azure CLI on your system

On Ubuntu/Debian Linux, requires sudo:

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

On MacOS, use homebrew:

```bash
brew update && brew install azure-cli
```

If the commands above don't work, please refer to: [https://aka.ms/azure-cli](https://aka.ms/azure-cli)

## 🔐 After Install - Login to Azure

The rest of this workshop assumes you have access to an Azure subscription, and have the Azure CLI working & signed into the tenant & subscription you will be using.
Some Azure CLI commands to help you:

- `az login` or `az login --tenant {TENANT_ID}` - Login to the Azure CLI, use the `--tenant` switch
  if you have multiple accounts.
- `az account set --subscription {SUBSCRIPTION_ID}` - Set the subscription the Azure CLI will use.
- `az account show -o table` - Show the subscription the CLI is configured to use.

## 💲 Variables File

Although not essential, it's advised to create a `vars.sh` file holding all the parameters that will
be common across many of the commands that will be run. This way you have a single point of reference
for them and they can be easily reset in the event of a session timing out or terminal closing.

Sample `vars.sh` file is shown below, feel free to use any values you wish for the resource group,
region cluster name etc. To use the file simply source it through bash with `source vars.sh`, do this
before moving to the next stage.

> 📝 NOTE: The ACR name must be globally unique and not contain dashes, dots, or underscores.

```bash
RES_GROUP="kube-workshop"
REGION="westeurope"
VM_NAME="__change_me__"
ACR_NAME="__change_me__"
```

## Navigation

[Return to Main Index 🏠](../../readme.md)
[Next Section ⏩](../01-cluster/readme.md)
