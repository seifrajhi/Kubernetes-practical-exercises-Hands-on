# Kubernetes Clusters

A single-node cluster is fine for a local environment, but a real cluster will always be multi-node for high availability and scale. 

In a production cluster the core Kubernetes components - called the control plane - run in dedicated nodes. You won't run any of your own app components on those nodes, so they're dedicated to Kubernetes. The control plane is usually replicated across three nodes. Then you have as many worker nodes as you need to run your apps, which could be tens or hundreds.

You can install Kubernetes on servers or VMs using the [Kubeadm](https://kubernetes.io/docs/reference/setup-tools/kubeadm/) tool. In the cloud you would use the command line or web UI for your platform (e.g. [az aks create](https://docs.microsoft.com/en-us/cli/azure/aks?view=azure-cli-latest#az_aks_create) for Azure, [eksctl create cluster](https://eksctl.io/usage/creating-and-managing-clusters/) for AWS and [gcloud container clusters create](https://cloud.google.com/kubernetes-engine/docs/quickstart#create_cluster) for GCP). We'll use k3d to create multi-node local environments.

## Reference

- [kubeadm init](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/) - to initialize a new cluster
- [kubeadm join](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-join/) - to join a new node to an existing cluster
- [k3d cluster create](https://k3d.io/v5.0.0/usage/commands/k3d_cluster_create/) - creating local clusers with k3d
- [Taints and tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) - marking nodes
- [Deprecated API Migration Guide](https://kubernetes.io/docs/reference/using-api/deprecation-guide/) - managing API version upgrades

## Cluster versions & API support

Kubernetes moves fast - there are three releases per year, and a release may add or change resource specifications. The API version in your YAML spec defines which resource version you're using, and not all clusters support all API versions.

k3d is great for spinning up specific Kubernetes versions quickly, so you can run the exact version you have in your production environment.

- Install k3d from the install instructions https://k3d.io/v5.4.4/#installation **OR**

The simple way, if you have a package manager installed:

```
# On Windows using Chocolatey:
choco install k3d

# On MacOS using brew:
brew install k3d

# On Linux:
curl -s https://raw.githubusercontent.com/rancher/k3d/main/install.sh | bash
```

Test you have the CLI working:

```
k3d version
```

> The exercises use k3d **v5**. Options have changed a lot since older versions, so if youre on v4 or earlier you'll need to upgrade.

Create two clusters, one using a recent Kubernetes version and one using an old release:

```
k3d cluster create labs-clusters-116 --image rancher/k3s:v1.16.15-k3s1

k3d cluster create labs-clusters-122 --image rancher/k3s:v1.22.2-k3s2
```

Switch to the older cluster and check the API versions:

```
kubectl config use-context k3d-labs-clusters-116

kubectl get nodes

kubectl api-versions
```

> You'll see `networking.k8s.io/v1beta1` - which contains a beta version of the Ingress spec

You can create a [beta Ingress spec](./specs/ingress/v1beta1/whoami.yaml) on this cluster:

```
kubectl apply -f labs/clusters/specs/ingress/v1beta1
```

Switch to the newer cluster and compare the API versions:

```
kubectl config use-context k3d-labs-clusters-122

kubectl api-versions
```

> `networking.k8s.io/v1beta1` is no longer listed

```
# the same YAML spec fails on this cluster:
kubectl apply -f labs/clusters/specs/ingress/v1beta1
```

You'll see:

 _error: unable to recognize "labs//clusters//specs//ingress//v1beta1//whoami.yaml": no matches for kind "Ingress" in version "networking.k8s.io/v1beta1"_
 
There's no fix for this - you need to update your YAML to use the [v1 Ingress spec](./specs/ingress/v1/ingress.yaml), which uses a different schema.

We don't need those clusters now, so we can remove them:

```
k3d cluster delete labs-clusters-116 labs-clusters-122
```

## Create a multi-node cluster

We'll create a multi-node cluster to see how Kubernetes manages Pods across multiple nodes.

This will build a cluster with one control plane node and two worker nodes, publishing ports so we can send traffic into NodePort Services using `localhost`:

```
k3d cluster create lab-clusters --servers 1 --agents 2 -p "30700-30799:30700-30799"
```

You can see the nodes are actually Docker containers:

```
docker container ls
```

📋 List the nodes showing extra details, including the container runtime, and then print all the labels for the nodes.

<details>
  <summary>Not sure how?</summary>

The wide output adds node IP address and component versions:

```
kubectl get nodes -o wide
```

Nodes are like any object, you can add labels to the output:

```
kubectl get nodes --show-labels
```

</details><br />

> All Kubernetes nodes have standard labels - including the hostname, operating system (Linux or Windows) and the CPU architecture (Intel or Arm). 

Control plane nodes have an additional label to identify them, and many platforms add their own labels (e.g. region and zone for cloud clusters).

## Taints and tolerations

The [Kubernetes scheduler](https://kubernetes.io/docs/concepts/scheduling-eviction/kube-scheduler/) decides which node should run a Pod. When you create a Pod it goes into the _Pending_ state and that's when the scheduler finds a node to run it.

Our k3d cluster is set up so all nodes can run pods; this [whoami Deployment](./specs/whoami/deployment.yaml) runs six replicas, so we should see every node running at least one Pod:

```
kubectl apply -f labs/clusters/specs/whoami
```

📋 List the whoami Pods, showing which node is running each Pod.

<details>
  <summary>Not sure how?</summary>

```
kubectl get po -o wide -l app=whoami
```

</details><br />

> You should see all the nodes running Pods - most likely the agent nodes will run more than the server node. The server node is the control plane, and it has less capacity for new Pods because it's running the system components.

Other Kubernetes platforms prevent applications running on the control plane by _tainting_ the node(s). Taints are like labels, but they affect Pod scheduling.

There will be no taints on any nodes so far:

```
kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints --no-headers 
```

You can create a taint which says Pods should only be scheduled for this node if they _tolerate_ that it's using HDD storage (this is a made-up example, taints can be any key-value pair):

```
kubectl taint nodes k3d-lab-clusters-agent-1 disk=hdd:NoSchedule
```

> A _NoSchedule_ taint doesn't affect Pods which are currently running, so you will still see whoami Pods running on agent-1.

To isolate the control plane you can apply a _NoExecute_ taint which means it shouldn't run any non-system Pods, so no new ones will be scheduled **and** any existing ones will be removed:

```
kubectl taint nodes k3d-lab-clusters-server-0 workload=system:NoExecute
```

> List the whoami Pods and you'll see the Pod(s) on the server node get terminated, and recreated on agent-0 

No new Pods will be created on agent-1 because of the taint, so if you rollout the Deployment again, all the Pods will run on agent-0:

```
kubectl rollout restart deploy whoami

kubectl get po -o wide -l app=whoami
```

This updated [Deployment spec](./specs/whoami/update/deployment.yaml) has a _toleration_ for the `disk=hdd` taint, which tells the scheduler this app can run on tainted nodes.

Apply the update:

```
kubectl apply -f labs/clusters/specs/whoami/update

kubectl get po -o wide -l app=whoami
```
> You'll see Pods are spread on agents 0 and 1, but not the control plane node because the spec doesn't tolerate the `workload=system` taint.

## Scheduling with Node Selectors

Tolerations say a Pod _can_ run on a tainted node, but they don't request that a Pod _will_ run on a tainted node. 

If you want to ensure Pods are scheduled on certain nodes you can do that with a node selector which identifies the node(s) you want by their labels.

- [ingress-controller/daemonset.yaml](./specs/ingress-controller/daemonset.yaml) - runs the Nginx Ingress Controller as a DaemonSet which will only run on Linux nodes, and tolerates the `disk=hdd` taint

Create the DaemonSet:

```
kubectl apply -f labs/clusters/specs/ingress-controller 
```

📋 DaemonSets create a Pod on each node. How many Pods do you expect to see?

<details>
  <summary>Not sure?</summary>

List the Pods in the namespace:

```
kubectl get po -o wide -n ingress-nginx
```

There are only two. The spec tolerates the `disk=hdd` taint so there's a Pod on agent-1, but not the `workload=system` taint so there's no Pod on the control plane node.

</details><br />

In some cases you might want Pods to run on the control plane only - this [updated DaemonSet spec](./specs/ingress-controller/update/daemonset.yaml) tolerates the workload taint and selects nodes with the control plane label.

Deploy the update and check the Pods:

```
kubectl apply -f labs/clusters/specs/ingress-controller/update

kubectl get po -n ingress-nginx -o wide
```

> Now there's a single Pod on the server node

___

## Lab 

Some node management needs to be done by the platform tools (e.g. kubeadm or the k3d command line), but you can do some admin tasks with Kubectl.

You can prepare a node for maintenance by having all the existing Pods removed and no new Pods scheduled. Do that for the agent-1 node, then bring it back online again so it can run Pods.

You'll find the whoami Deployment is not well balanced because all the Pods moved to agent-0 during the maintenance window, so you'll need to find a way to spread the Pod across both worker nodes again.

> Stuck? Try [hints](hints.md) or check the [solution](solution.md).

___

## EXTRA Adding and removing nodes

<details>
  <summary>Explore how the cluster behaves when nodes come and go</summary>

You can simulate a server going offline with k3d by stopping a node:

```
k3d node stop k3d-lab-clusters-agent-1
```

Check the nodes and you'll see the status update:

```
kubectl get nodes --watch
```
> The node stops straigt away, but it takes 30+ sec for Kubernetes to notice. There's a heartbeat sent from nodes to the control plane so Kubernetes waits to make sure the node is really offline. The status of agent-1 changes to _NotReady_

Check the Pods and you'll find all the Pods which were running on agent-1 get terminated and replaced on other nodes:

```
kubectl get po -o wide -A
```

> The old stay as Terminating - the node isn't online to confirm they've been removed


Delete the agent-1 node:

```
kubectl delete node k3d-lab-clusters-agent-1

kubectl get nodes
```

This removes the node from the cluster, it doesn't impact the server itself.

Create a replacement node:

```
k3d node create -c lab-clusters new-node

kubectl get nodes --watch
```

> You'll see the new node joins, then goes from the NotReady to Ready state. There will be no Pods running on this node, until some get created and scheduled.

When worker nodes go offline, Kubernetes keeps your apps running by replacing the lost Pods. When control plane nodes go offline you can lose access to your cluster - which is why you need 3 (or 5 or 7) control plane nodes for high availability.

Stop your control plane:

```
k3d node stop k3d-lab-clusters-server-0
```

Try to list nodes (or anything else):

```
kubectl get nodes 
```
> You'll get a timeout because there's no API server running to respond to Kubectl

</details><br />

___

## Cleanup

Remove your k3d cluster:

```
k3d cluster delete lab-clusters
```

And switch back to your previous cluster:

```
kubectl config use-context docker-desktop  # or your cluster name
```
