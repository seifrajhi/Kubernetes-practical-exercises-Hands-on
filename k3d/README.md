Table of Contents
=================

   * [What is k3d?](#what-is-k3d)
   * [Requirements](#requirements)
      * [ Install Script](#install-script)
         * [Install current latest release](#install-current-latest-release)
         * [Install specific release](#install-specific-release)
   * [Creating single-node clusters:](#creating-single-node-clusters)
   * [Creating additional clusters](#creating-additional-clusters)
   * [Deleting clusters](#deleting-clusters)
   * [Creating clusters through configs](#creating-clusters-through-configs)
         * [Open <a href="http://localhost" rel="nofollow">http://localhost</a> in a browser.](#open-httplocalhost-in-a-browser)
   * [Deleting clusters](#deleting-clusters-1)
   * [Speed test against kind](#speed-test-against-kind)
      * [Please go through kind module if you are not already familiar with kind](#please-go-through-kind-module-if-you-are-not-already-familiar-with-kind)
* [Reference link:](#reference-link)


## What is k3d?

k3d is a lightweight wrapper to run [k3s](https://github.com/rancher/k3s) (Rancher Lab’s minimal Kubernetes distribution) in docker.

k3d makes it very easy to create single- and multi-node [k3s](https://github.com/rancher/k3s) clusters in docker, e.g. for local development on Kubernetes.

## Requirements

-   [**docker**](https://docs.docker.com/install/) to be able to use k3d at all
    -   Note: k3d v5.x.x requires at least Docker v20.10.5 (runc >= v1.0.0-rc93) to work properly.
-   [kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl) to interact with the Kubernetes cluster


###  Install Script

#### Install current latest release

-   wget:

```
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
```

-   curl:

```
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | bash
```


#### Install specific release

Use the install script to grab a specific release (via `TAG` environment variable):

-   wget:

```
wget -q -O - https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | TAG=v5.0.0 bash
```

-   curl:

 ```
curl -s https://raw.githubusercontent.com/k3d-io/k3d/main/install.sh | TAG=v5.0.0 bash
```


## Creating single-node clusters:

Here, we are creating `cluster-1`:

```
k3d cluster create cluster-1
```

Here, we can see the cluster running as container:

```
docker container ls
```

k3s is the cluster running as container and the proxy container which will proxy the requests entering into docker and going into that cluster.

Here, list out the pods:

```
kubectl get pods -A
```

Here, list out the nodes:

```
kubectl get nodes
```

## Creating additional clusters

Here, we are specifying an image (kubernetes version) to create `cluster-2`.

```
k3d cluster create cluster-2 --image rancher/k3s:v1.20.4-k3s1
```

Here, we can see the cluster running as container:

```
docker container ls
```


## Deleting clusters
Here is the way to delete the cluster:

```
k3d cluster delete cluster-1
```

```
k3d cluster delete cluster-2
```


## Creating clusters through configs

Clone the repository:

```
git clone https://github.com/vfarcic/k3d-demo.git
```

```
cd k3d-demo
```

Here, we can see the config file and review it:

```
cat k3d.yaml
```

 Please note [kind](https://k3d.io/v5.4.6/usage/configfile/#required-fields) to define the kind of config file that you want to use (currently k3d only have the `Simple` config)

```yaml
kind: Simple #simple type of cluster

apiVersion: k3d.io/v1alpha2

name: my-cluster

image: rancher/k3s:v1.20.4-k3s1 #version of kubernetes we want to run in this cluster

servers: 3 #controlplane

agents: 3 #workernode

ports:

- port: 80:80

  nodeFilters:

  - loadbalancer

# options:

#   k3s:

#     extraServerArgs:

#     - --no-deploy=traefik
```

Here, we will create the cluster using config file:

```
k3d cluster create --config k3d.yaml
```

Here, list out the nodes:

```
kubectl get nodes
```

Here, we apply the definition files:

```
kubectl apply --filename k8s/
```

#### Open http://localhost in a browser.


## Deleting clusters #

```
k3d cluster delete my-cluster
```

## Speed test against kind

```
docker system prune -a -f --volumes
```

```
k3d cluster create my-cluster
```

```
k3d cluster delete my-cluster
```

### Please go through kind module if you are not already familiar with kind

```
kind create cluster --name my-cluster
```

```
kind delete cluster --name my-cluster
```



# Reference link:

- [K3d - How to run Kubernetes cluster locally using Rancher K3s](https://www.youtube.com/watch?v=mCesuGk-Fks)
- [gist](https://gist.github.com/vfarcic/b025359ef5ba33353476bbfe881ec5c3)
- [k3d Installation](https://k3d.io/v5.4.6/)