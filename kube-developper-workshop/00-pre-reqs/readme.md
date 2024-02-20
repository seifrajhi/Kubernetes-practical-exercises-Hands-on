# ⚒️ Workshop Pre Requisites

As this is a completely hands on workshop, you will need several things before you can start:

- Access to an Azure Subscription where you can create resources.
- bash or a bash compatible shell (e.g. zsh), please do not attempt to use PowerShell or cmd.
- A good editor, and [VS Code](https://code.visualstudio.com/) is strongly recommended
  - [Kubernetes extension](https://marketplace.visualstudio.com/items?itemName=ms-kubernetes-tools.vscode-kubernetes-tools) also highly recommended.
- [Azure CLI](https://aka.ms/azure-cli)
- [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/)
- [helm](https://helm.sh/docs/intro/install/)

## Install dependencies

The above listed tools are already set up in `.devcontainer` folder located in the git repository of this workshop: <https://github.com/benc-uk/kube-workshop>.
If you've never used Dev Containers, check out [developing inside a Container using Visual Studio Code Remote Development](https://code.visualstudio.com/docs/devcontainers/containers).

### Install dependencies manually

Alteratively you can can install the dependencies yourself by following the steps below.

#### 🌩️ Install Azure CLI

To set-up the Azure CLI on your system, install it in one of the below ways.

On Ubuntu/Debian Linux, requires sudo:

```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

On MacOS, use homebrew:

```bash
brew update && brew install azure-cli
```

If the commands above don't work, please refer to: [https://aka.ms/azure-cli](https://aka.ms/azure-cli)

#### ⛑️ Install Helm & Kubectl

<details markdown="1">
<summary>Install Helm & Kubectl - Linux (Ubuntu/Debian)</summary>

Two ways are provided for each tool, one without needing sudo, the other requires sudo, take your pick but don't run both!

By default the 'no sudo' commands for helm & kubectl install binaries into `~/.local/bin` so if this isn't in your PATH you can copy or move the binary elsewhere, or simply run `export PATH="$PATH:$HOME/.local/bin"`

```bash
# Install kubectl - no sudo
curl -s https://raw.githubusercontent.com/benc-uk/tools-install/master/kubectl.sh | bash

# Install kubectl - with sudo
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/bin/kubectl

# Install helm - no sudo
curl -s https://raw.githubusercontent.com/benc-uk/tools-install/master/helm.sh | bash

# Install helm - with sudo
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

</details>

<details markdown="1">
<summary>Install Helm & Kubectl - MacOS</summary>

```bash
# Install kubectl - with sudo
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"
chmod +x ./kubectl
sudo mv ./kubectl /usr/local/bin/kubectl

# Install Helm
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

</details>

#### ⚙️ Set up bash profile

Set up the user bash profile for K8s to make it easier to run all the commands

```sh
echo "source <(kubectl completion bash)" >> ~/.bashrc
echo "alias k=kubectl" >> ~/.bashrc
echo "complete -o default -F __start_kubectl k" >> ~/.bashrc
echo "export PATH=$PATH:/home/azureuser/.local/bin" >> ~/.bashrc
```

To have `.bashrc` changes take affect in your current terminal, you must reload `.bashrc` with:

```sh
. ~/.bashrc
```

## ✅ Verify installation

Double check that everything in installed and working correctly with:

```sh
# Try commands with tab completion
k get pods -A
helm
az
```

## 🔐 Login to Azure

The rest of this workshop assumes you have access to an Azure subscription, and have the Azure CLI
working & signed into the tenant & subscription you will be using. Some Azure CLI commands to help you:

- `az login` or `az login --tenant {TENANT_ID}` - Login to the Azure CLI, use the `--tenant` switch
  if you have multiple accounts.
- `az account set --subscription {SUBSCRIPTION_ID}` - Set the subscription the Azure CLI will use.
- `az account show -o table` - Show the subscription the CLI is configured to use.

## 😢 Stuck?

Getting all the tools set up locally is the highly recommended path to take, if you are stuck there
are some other options to explore, but these haven't been tested:

- Use the [Azure Cloud Shell](https://shell.azure.com/bash) which has all of these tools except VS Code,
  a simple web code editor is available. However if you download the
  [VS Code server](https://aka.ms/install-vscode-server/setup.sh), then run that from inside Cloud Shell
  you can get access to the full web based version of VS Code.
- Go to the [repo for this workshop on GitHub](https://github.com/benc-uk/kube-workshop/codespaces)
  and start a new Codespace from it, you should get a terminal you can use and have all the tools available.
  Only available if you have access to GitHub Codespaces.

## 💲 Variables File

Although not essential, it's advised to create a `vars.sh` file holding all the parameters that will
be common across many of the commands that will be run. This way you have a single point of reference
for them and they can be easily reset in the event of a session timing out or terminal closing.

Sample `vars.sh` file is shown below, feel free to use any values you wish for the resource group, region cluster name etc.

> Note: The ACR name must be globally unique and cannot contain hyphens, dots, or underscores.

```bash
RES_GROUP="kube-workshop"
REGION="westeurope"
AKS_NAME="__change_me__"
ACR_NAME="__change_me__"
KUBE_VERSION="1.27.1"
```

> Note: New versions of Kubernetes are released all the time, and eventually older versions are removed from Azure. Rather than constantly update this guide the following command can be used to get the latest version: `az aks get-versions --location "westeurope" -o tsv --query "orchestrators[-1].orchestratorVersion"`

To use the file simply source it through bash with the below command, do this before moving to the next stage.

```sh
source vars.sh
```

It's worth creating a project folder locally (or even a git repo) at this point, in order to keep your work in, you haven't done so already. We'll be creating & editing files later

## Navigation

[Return to Main Index 🏠](../readme.md) ‖ [Next Section ⏩](../01-cluster/readme.md)
