Table of Contents
=================

- [Table of Contents](#table-of-contents)
- [Kind](#kind)
  - [Prerequisites:](#prerequisites)
    - [Installing With A Package Manager](#installing-with-a-package-manager)
    - [Installing From Release Binaries](#installing-from-release-binaries)
  - [Creating a Cluster](#creating-a-cluster)
  - [Interacting With Your Cluster](#interacting-with-your-cluster)
  - [Deleting a Cluster](#deleting-a-cluster)
- [Summary](#summary)
- [Reference link:](#reference-link)


# Kind

kind is a tool for running local Kubernetes clusters using Docker container “nodes”.
kind was primarily designed for testing Kubernetes itself, but may be used for local development or CI.

## Prerequisites: 

- Install Docker Desktop if you are on macOS or Windows OS, or Docker if Linux OS

- If you are on Windows/macOS disable kubernetes from docker desktop if you are using it! As we are using the kind and we need to avoid the duplication.



### Installing With A Package Manager

The kind community has enabled installation via the following package managers.

On macOS via Homebrew:

```bash
brew install kind
```

On macOS via MacPorts:

```bash
sudo port selfupdate && sudo port install kind
```

On Windows via Chocolatey 

```powershell
choco install kind
```

### Installing From Release Binaries

Pre-built binaries are available on our [releases page](https://github.com/kubernetes-sigs/kind/releases).

To install, download the binary for your platform from “Assets”, then rename it to `kind` (or perhaps `kind.exe` on Windows) and place this into your `$PATH` at your preferred binary installation directory.

On Linux:

```bash
curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.16.0/kind-linux-amd64
chmod +x ./kind
sudo mv ./kind /usr/local/bin/kind
```

On macOS:

```bash
# for Intel Macs
[ $(uname -m) = x86_64 ]&& curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.16.0/kind-darwin-amd64
# for M1 / ARM Macs
[ $(uname -m) = arm64 ] && curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.16.0/kind-darwin-arm64
chmod +x ./kind
mv ./kind /some-dir-in-your-PATH/kind
```

On Windows in [PowerShell](https://en.wikipedia.org/wiki/PowerShell):

```powershell
curl.exe -Lo kind-windows-amd64.exe https://kind.sigs.k8s.io/dl/v0.16.0/kind-windows-amd64
Move-Item .\kind-windows-amd64.exe c:\some-dir-in-your-PATH\kind.exe
```

## Creating a Cluster

Creating a Kubernetes cluster is as simple as 

```
kind create cluster --name cluster-1
kubectl cluster-info --context kind-cluster-1
kubectl get nodes
```

Next, run below command which will show us the node as container:

```
docker container ls
```

Next, below command will show us the control plane node:

```
kubectl get nodes
```

## Interacting With Your Cluster

By default, the cluster access configuration is stored in ${HOME}/.kube/config if $KUBECONFIG environment variable is not set.

Let's create another cluster:

```
kind create --name cluster-2
```

When you list your kind clusters, you will see something like the following:

```
kind get clusters

cluster-1
cluster-2
```


## Deleting a Cluster

If you created a cluster with `kind create cluster` then deleting is equally simple:

```
kind delete cluster
```

If the flag `--name` is not specified, kind will use the default cluster context name `kind` and delete that cluster.

```
kind delete cluster-1
```

```
kind delete cluster-2
```

A config file with six nodes that enables the clusters with ingress.

```
git clone https://github.com/vfarcic/kind-demo.git
```

```
cd kind-demo
```

```
cat multi-node.yaml
```

```
kind create cluster --config multi-node.yaml
```

We will see there are three control-plane nodes and three worker nodes.

```
kubectl get nodes
```


Next, run below command which will show us the node as container:

```
docker container ls
```

You will see total seven containers; one container is used for forwarding request between docker desktop and kind to offer ingress. The other are control-plane and worker nodes.

The k8s folder contains the deployment, ingress and service yaml files:

```
kubectl apply --filename k8s/
```

Go to Google chrome:

```
http://localhost
```

We won't be able to see the page as nginx-ingress is not installed out of the box with kind.

We can install it by running following command:

```
kubectl apply --filename ingress-nginx-deploy.yaml
```

Go to Google chrome:

```
http://localhost
```

# Summary
kind creates kubernetes clusters as containers.

kind is creating control-plane node and worker node as containers.

For Linux users, use kind or Docker Desktop.

For Windows and MacOS users, Docker Desktop (Kubernetes built-in) option is available unless you want to run multi-node cluster and multiple clusters.

# Reference link: 

- [Kind Installation](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)

- [How to run local multi-node Kubernetes clusters using kind](https://www.youtube.com/watch?v=C0v5gJSWuSo)

- [multi-node.yaml](https://github.com/vfarcic/kind-demo/blob/master/multi-node.yaml)