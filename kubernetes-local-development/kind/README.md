# Kind

https://kind.sigs.k8s.io/

## Installation

```bash
./kind_install.sh [VERSION]
```

## TL;DR

```bash
# 1 node cluster
kind create cluster
export KUBECONFIG="$(kind get kubeconfig-path --name="kind")"
kubectl cluster-info

# 3 masters + 3 workers cluster
kind create cluster --confifg cplane-ha.yml
export KUBECONFIG="$(kind get kubeconfig-path --name="kind")"
kubectl cluster-info
kubectl get nodes
```

## Usage

Create a kind cluster :

```bash
kind create cluster
```

Interact with the cluster :

```bash
export KUBECONFIG="$(kind get kubeconfig-path --name="kind")"
kubectl cluster-info
```

Load a docker image in the cluster :

```bash
kind load docker-image my-custom-image
```

Delete a kind cluster :

```bash
kind delete cluster
```

## Configuring your kind cluster

Is it possible to use a configuration file to customize your kind cluster (Multi-Node, Control-Plane HA...)

```bash

# Create a cluster with 3 control-plane nodes and 3 workers
kind create cluster --config cplane-ha.yml

# Create a cluster with 1 control-plane nodes and 3 workers
kind create cluster --config multinode.yml

```

See https://kind.sigs.k8s.io/docs/user/quick-start/#configuring-your-kind-cluster for details.

## Auto Completion

To enable completion :

```bash
# for bash users
kind completion bash > ~/.kind-completion
source ~/.kind-completion

# for zsh users
kind completion zsh > /usr/local/share/zsh/site-functions/_kind
autoload -U compinit && compinit
```

## Ingress with kind

https://banzaicloud.com/blog/kind-ingress/

![Expose ports when deploying to kind](https://banzaicloud.com/img/blog/kind/kind-socat.png)
