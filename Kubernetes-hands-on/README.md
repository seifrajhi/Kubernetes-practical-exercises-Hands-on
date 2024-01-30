<div align="center">
  <a href="https://github.com/Krishnamohan-Yerrabilli/Kubernetes-hands-on">
    <img src="https://user-images.githubusercontent.com/58173938/196433324-45e814cb-fb4d-4807-9134-af30e45e9ea6.png" alt="kuber" width="200" height="200">
  </a>
</div>

<br>
<div align="center">
This repository contains a record of my learning journey, including detailed explanations and practical examples of various concepts such as Configmap, secrets, and RBAC. There are many other topics covered as well. This repository serves as a record of my progress and understanding in these areas. I have put a lot of effort into creating and organizing these resources, and I hope that they will be useful to others as well. If you find this repository helpful and want to use its contents for your own purposes, you are welcome to fork it. If you appreciate the time and effort that went into creating this repository, please consider leaving a ⭐ to show your support. Thank you, happy learning!
</div>
<br>

# Kubernetes-hands-on

## Prerequisites

install Minikube on linux by following these steps:

- Download the latest release of Minikube from the releases page at https://github.com/kubernetes/minikube/releases.
- Extract the downloaded file and move it to a directory in your PATH. For example:

```s
tar -xvf minikube-linux-amd64.tar.gz
sudo mv minikube /usr/local/bin
```
Start Minikube by running the following command:

```
minikube start
```
Once Minikube is up and running, you can use the kubectl command-line tool to deploy and manage applications on the cluster.

This will start a single-node Kubernetes cluster using the default configuration. If you want to customize the configuration, you can use the --vm-driver flag to specify the hypervisor to use and the --cpus and --memory flags to set the number of CPUs and memory allocated to the virtual machine, respectively.

For MAC:

* Homebrew: <https://brew.sh/>

```sh
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

* Docker: <https://docs.docker.com/docker-for-mac/install/>

```sh
open https://download.docker.com/mac/stable/Docker.dmg
```

* VirtualBox: <https://www.virtualbox.org/wiki/Downloads>

* minikube: <https://github.com/kubernetes/minikube>

Install minikube and the "ingress" and "metrics-server" addons:

```sh
$ brew install kubectl
[...]

$ brew cask install minikube
[...]

$ minikube start
[...]
🏄  Done! Thank you for using minikube!

$ minikube addons enable ingress
✅ ingress was successfully enabled

$ minikube addons enable metrics-server
✅  metrics-server was successfully enabled

$ kubectl config current-context
minikube
```

**Note:** the ingress addon is currently not supported on docker for Mac (see https://github.com/kubernetes/minikube/issues/7332).
As a workaround, you have to deploy minikube as a VM and not as a container (using Virtualbox or Hyperkit for example)

```sh
$ minikube start --vm=true --vm-driver=virtualbox
[...]
✨  Using the virtualbox driver based on user configuration
🔥  Creating virtualbox VM ...
```

If you did launch minikube already, the `--vm` flag may be ignored as minikube caches the previous config. If so you may want to delete and relaunch minikube (warning: it will delete your whole minikube setup)

```sh
$ minikube stop && minikube delete && minikube start --vm=true --vm-driver=virtualbox
[...]
💀  Removed all traces of the "minikube" cluster.
✨  Using the virtualbox driver based on user configuration
🔥  Creating virtualbox VM ...
```
### Completion

If you are using Zsh, you can add the following to your `.zshrc` file to get autocomplete for `kubectl`:

```sh
if [ $commands[kubectl] ]; then
  source <(kubectl completion zsh)
fi
```

## What is Kubernetes?

Kubernetes is an open-source platform "Orchestration engine" mainly used to manage
containerized applications, it is released by Google in 2014, and the project is donated 
to CNCF (Cloud-native computing foundation), primarily it serves `micro-services` applications,
and it is still the world's `second-biggest` project in open source after Linux.

## Why use Kubernetes?

An `orchestration` engine helps to watch and control `containerized` applications very closely, 
and it is also used to automate certain functions, let me give an example for a better 
understanding this broad topic, Let's say one of your application service's containers went down,
it's not such a big deal to manually `restart` the container, but what if a large number of containers
went down suddenly, wouldn't be easy this task will be automatically done, this is where Kubernetes comes, k8's will restart the containers, not only that it also provides many `services` such as logging,
load balancing, secret, scheduling, scaling, fault-tolerance, deployment.

## Kubernetes architecture

<div align="center">
  <a href="https://github.com/Krishnamohan-Yerrabilli/Kubernetes-hands-on">
    <img src="https://github.com/Krishnamohan-Yerrabilli/Kubernetes-hands-on/assets/58173938/a77033ad-8ed4-4f5e-afe8-d8ba9f0cbbcf" alt="kuber" width="800" >
  </a>
</div>

### Brief 

Kubernetes architecture has the master node, which is also called as control plane nowadays, 
which controls the nodes.these nodes are nothing but physical servers or VMs, which are run 
inside a data center applications are run inside the node, these nodes are previously called 
minions, In that, we have a lot of components such as type of service, cluster, pod. 

### Master Node aka (Control plane)

<br>
<div align="center">
  <a href="https://github.com/Krishnamohan-Yerrabilli/Kubernetes-hands-on">
    <img src="https://user-images.githubusercontent.com/58173938/207633973-993c60de-5821-4d93-ae35-41a6f68ce5ee.png" alt="kuber" width="800">
  </a>
</div>
<br>

The Control plane acts like a mother to all worker nodes, It is responsible for doing many 
operations, such as scheduling worker nodes, taking control of the whole cluster, majorly 
it has 4 components API server, control manager, etcd, scheduler, the primary component 
in the cluster is the API server which communicates with the host and many other parts in 
the cluster, the control manager takes control of the fault tolerance, and many more, such 
as if any pods(which we see in a bit), etcd holds our desired state data(YAML files which we
 see in a bit), and scheduler which schedules pods on available nodes.

### Components of the Master Node

#### API server

API server acts like the heart of the cluster, without API services we can't interact with k8's 
cluster, The role of the API server is to communicate with other components in the cluster, 
such as scheduler, etcd, control manager, kubelet, kube-proxy it's mandatory to communicate 
to have API server in between them.

#### Control Manager

The control manager's role is to It continuously checks whether the given desired state is 
running or not, suppose we want to deploy the application in 3 nodes, assume 3 pods 
have been allocated for three different nodes, now what if 1 pod is down, what if 3 pods 
have been down, there were control manager comes into rescue, it takes the information 
which provide by the node and the etcd, and check whether the given state is equal to 
the current state, if it does not satisfy the desired state then the control manager restarts a 
new pod, by using different types of controllers. 

There are lot of types of controllers beyond the control manager some of the important one's are

- Node controller
- Deployment controller
- Replication controller
- Endpoint controller
- Service-token controller

#### Etcd 

etcd holds the desired state, in the sense of key-value pairs stored for shared configuration, 
Kubernetes is a distributed system, so it wants a distributed storage to store the desired state, 
the desired state is nothing but a client requirement, and it also stores data about the current status, 
and metadata.

#### Scheduler

Its role is to assign pods to the nodes, it's job is to check the suitable nodes by means 
of given constraints and available resources, then it schedules the pods to the nodes, 
it is done by following Kubernetes scheduling principles.

### Worker node

Its job is to run the containers in the pods on the node. a single node has multiple pods.
worker nodes are part of the Kubernetes cluster.

<br>

<div align="center">
  <a href="https://github.com/Krishnamohan-Yerrabilli/Kubernetes-hands-on">
    <img src="https://user-images.githubusercontent.com/58173938/208225446-a9c3a5c7-e440-41ce-b777-ff3b171b87d7.jpg" alt="kuber">
  </a>
</div>

### Components of the worker node

#### Kubelet

kubelet is also called an agent node, because it lives on top of every node in the 
Kubernetes cluster, its main job is to take the pod spec from the API server, and after 
that it talks to grpc (google remote procedure calls) over from the UNIX sockets and 
then the info goes through the runtime CRI (container runtime interface) shim (docker) 
and any other and then it creates pods as described in the pod spec, and it makes sure 
the containers are in the running state.

<br>

<div align="center">
  <a href="https://github.com/Krishnamohan-Yerrabilli/Kubernetes-hands-on">
    <img src="https://user-images.githubusercontent.com/58173938/192191843-cc474485-bddd-491c-b918-493762812654.png" alt="kuber" width="600" height="250">
</a>
</div>

<div align="center">
Here the kubelet acts as the client, and CRI shim as the server.
</div>

#### kube-proxy

Its job is to direct the incoming requests from the client to the designated pods in the 
node, to the appropriate pods, but how is it possible through some service(service 
is an object in Kubernetes) a service is worked by depending on some rules which are provided 
by Kube-proxy, based on these rules load balancing would be done. 
<br>
<div align="center">
  <a href="https://github.com/Krishnamohan-Yerrabilli/Kubernetes-hands-on">
    <img src="https://user-images.githubusercontent.com/58173938/192191859-8a41946e-1cc6-41bd-9ece-1e4216ad05ae.png" alt="kuber" width="800" height="500">
  </a>
</div>

#### Pods

A pod is the smallest unit in the Kubernetes, like a container, is the smallest unit in the docker 
such as a pod in the K8. A pod's job is to run the containers inside it, containers are wrapped 
by a pod, and we interact and manage containers through the pod. there is an outline where we 
want to run multiple containers in the same pod, like one container helping to another container. 

#### Containers 

This is where the real application is running, this is where the actual thing happens, we run 
containerized applications inside the containers, this are actually built by docker image, 
containers are basically invented to run micro-services, if you want to learn more about 
this you can check out my blog on Docker.
<br>

### Complete Architecture

<div align="center">
  <a href="https://github.com/Krishnamohan-Yerrabilli/Kubernetes-hands-on">
    <img src="https://user-images.githubusercontent.com/58173938/208247626-7db13e5c-c857-45da-852e-a39e4e322bd9.jpg" alt="kuber">
  </a>
</div>

### Installation

#### Play with K8s 

If you want to start playing with k8's, or you want to test something in an Kubernetes 
environment, to this you don't pay to any cloud provider, play with K8 is a playground 
which allows users to run K8s clusters in a matter of seconds, for any review purposes also 
you can use it, to get started you just need a docker or a GitHub account, for more information 
you can refer to this [link](https://labs.play-with-k8s.com/).

#### Minikube

This is my favorite one, Minikube it helps to interact with Kubernetes in a local environment, 
it provides a single cluster, the same system acts as a master as well as worker node, but 
this has 1 drawback this performance is fully based on your PC resources, which means it will be 
work with limited resources, to note Minikube is not for production environment. for more
information on Minikube you can refer to this [Link](https://minikube.sigs.k8s.io/docs/start/)

#### Cloud Platforms 

So many cloud providers can provide Kubernetes cluster by buying their resources, 
each cloud provider has their own Kubernetes model, but under the hood all works 
on the same principle, like aws has EKS(Elastic Kubernetes Service), Microsoft azure has
 their own AKS (Azure Kubernetes Service), GCP has its GKE(google's Kubernetes 
engine), and Digital ocean has its DOKS(Digital ocean Kubernetes service) and many
 cloud providers have adopted k8's for their own functionality and for their different client needs.


#### More about Pods

Every node in the cluster has a unique IP address, and each pod inside the node has
 a dedicated IP address assigned to it, pods communicate with the outside world by 
using network namespaces this is assigned to the pods, multiple containers share 
the same IP address inside the single node to communicate with each other, this is 
also means they will share the same volumes, Cgroup limits, and even IPC names.

### Pod Networking 

### How pods communicate with each other? 

- Inter-Pod communication: All the Pod IP addresses are fully routable on the Pod Network inside the Kubernetes cluster.
  Containers use a shared Local Host interface. All the containers can communicate with each other’s ports on localhost
  <br>

<div align="center">
  <a href="https://github.com/Krishnamohan-Yerrabilli/Kubernetes-hands-on">
    <img src="https://kubebyexample.com/sites/default/files/2021-06/pod-to-service.svg_.png" alt="kuber">
  </a>
</div>

<p>

### Additional Resources

[Kubernetes Interactive Tutorial](https://kubernetes.io/docs/tutorials/kubernetes-basics/)

[Katakoda Learn Kubernetes](https://katacoda.com/courses/kubernetes)

[Configure a Pod to use Storage Volumes](https://kubernetes.io/docs/tasks/configure-pod-container/configure-volume-storage/)

[Observability - Honeycomb](https://www.honeycomb.io/kubernetes/)

[Observability - OpenTelemetry](https://opentelemetry.io/)

[Cloud Native Computing Foundation Landscape](https://landscape.cncf.io/)

