# Scheduling with Pod and Node Affinity

Affinity is a feature where you can request Pods to be scheduled in relation to other Pods or nodes. You might want to run multiple Pods in a Deployment and have them all running on different nodes, or you might have a web application where you want web Pods running on the same node as API Pods.

You add affinity rules to your Pod specification. They can be _required_ rules, which means they act as a constraint and if they can't be met then the Pod stays in the pending state. Or they can be _preferred_ rules, which means Kubernetes will try to meet them, but if it can't it will schedule the Pods anyway.

## Reference

- [Affinity and anti-affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity) - applying to nodes and Pods

- [Affinity API spec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#affinity-v1-core) - part of the Pod spec

- [Standard node labels & taints](https://kubernetes.io/docs/reference/labels-annotations-taints/) - which you can use for node affinity

## Node affinity

We'll use a multi-node cluster so we can see how Pods get placed. [k3d](https://k3d.io) is a great tool for that.

- Install k3d from the install instructions https://k3d.io/v5.0.0/#installation **OR**

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

_Create a 3-node cluster where each worker node is restricted to running a maximum of 5 Pods, and the extra stuff k3d installs is turned off:_

```
k3d cluster create labs-affinity --servers 1 --agents 2 -p "30780-30799:30780-30799" --k3s-arg '--kubelet-arg=max-pods=5@agent:*' --k3s-arg '--disable=metrics-server@server:0' --k3s-arg '--disable=traefik@server:0'
```

Check the node list and confirm agent-1 has a capacity of 5 Pods:

```
kubectl get nodes

kubectl describe node k3d-labs-affinity-agent-1
```

📋 The control plane node doesn't have a specific Pod capacity set. What is the default capacity?

<details>
  <summary>Not sure how?</summary>

You can print the details of the node and scroll to see the capacity:

```
kubectl describe node k3d-labs-affinity-server-0
```

Or you can print the Pod capacity directly with JSONPath:

```
kubectl get node k3d-labs-affinity-server-0 -o jsonpath='{.status.capacity.pods}'
```

> You'll see the default capacity is 110 Pods, which is one of the [best practice recommendations](https://kubernetes.io/docs/setup/best-practices/cluster-large/)

</details><br/>

Create this [whoami Deployment](./specs/whoami/deployment.yaml) which runs six replicas:

```
kubectl apply -f labs/affinity/specs/whoami
```

Check the Pods and you'll see they've been scheduled across all the nodes:

```
kubectl get pods -l app=whoami -o wide
```

> In the [clusters lab](../clusters/README.md) we saw how to use taints and tolerations, and node selectors to schedule Pods - but those options are not as flexible as affinity.

If we want to run all the Pods on nodes which have been verified as [CIS compliant](https://www.aquasec.com/cloud-native-academy/kubernetes-in-production/kubernetes-cis-benchmark-best-practices-in-brief/) we could add a label to the nodes and use a node selector; but if we wanted to restrict to worker nodes and not the control plane, we would have to use taints and tolerations.

Node affinity lets you set both requirements in one place:

- [compliance-required/deployment.yaml](./specs/whoami/compliance-required/deployment.yaml) - uses the standard role label to keep Pods away from control plane nodes, and a custom CIS label to place Pods on verified nodes

> This is a _requiredDuringSchedulingIgnoredDuringExecution_ rule which means it has to be met when Pods are scheduled, but existing Pods won't be removed if they don't meet the requirements.

📋 Apply the update in the `labs/affinity/specs/whoami/compliance-required`. What happens to the existing Pods?

<details>
  <summary>Not sure?</summary>

Apply the change:
```
kubectl apply -f labs/affinity/specs/whoami/compliance-required
```

If you watch the ReplicaSets you'll see the existing RS gets scaled down by one Pod and a new RS gets created, but it never scales up to full capacity:

```
kubectl get rs -l app=whoami --watch
```

The affinity rule doesn't affect existing Pods, but the rule is part of the Pod spec and a change to the Pod spec is rolled out by the Deployment as a new ReplicaSet.

</details><br/>

List the Pods now and you'll see the app is not at full capacity:

```
kubectl get pods -l app=whoami -o wide
```

> There are 5 Pods from the original Pod spec - only one was terminated in the update; 3 new Pods are all in the _Pending_ state.

📋 Why are the Pods pending? What can you do to the agent-1 node to have all the Pods scheduled on it?

<details>
  <summary>Not sure?</summary>

Describe one of the new Pods (it has an extra label applied to help with that):

```
kubectl describe po -l app=whoami,update=compliance-required
```

You'll see the problem:

_Warning  FailedScheduling  44s   default-scheduler  0/3 nodes are available: 3 node(s) didn't match Pod's node affinity/selector._

The affinity rule requires a node with the label `cis-compliance=verified`; you can add that to the agent-1 node:

```
kubectl label node k3d-labs-affinity-agent-1 cis-compliance=verified
```

</details><br/>

When your node is ready, check the ReplicaSets:

```
kubectl get rs -l app=whoami
```

> You'll see some of the new Pods get scheduled and start running (these will be on agent-1). The new ReplicaSet scales up, and the old one scales down - but not to full capacity.

The rollout can't complete. Describe the new Pods again and you'll see the problem:

```
kubectl describe po -l app=whoami,update=compliance-required
```

_Warning  FailedScheduling  3m24s  default-scheduler  0/3 nodes are available: 1 Too many pods, 2 node(s) didn't match Pod's node affinity/selector._

Only one node matches the affinity requirements, and it is configured to run a maximum of 5 Pods. It has no capacity to run more Pods so new ones can't be started to replace the old ones.

## Node topology

A more typical use for affinity is to enforce a spread of Pods across the nodes in a cluster. This depends on the cluster's _topology_, where the location of the nodes is represented in labels.

Every cluster adds a _hostname_ label which uniquely identifies each node:

```
kubectl get nodes -L kubernetes.io/hostname
```

> This is the Lowest level of topology - every node has a different label value

Clusters usually add more labels to represent the geography of the nodes. Cloud services typically add _region_ labels to identify the datacenter where the node is running, and also _zone_ labels to identify the failure zone within the region.

We'll simulate that in our cluster to give us regions and zones to work with:

```
kubectl label node --all topology.kubernetes.io/region=lab

kubectl label node k3d-labs-affinity-server-0 topology.kubernetes.io/zone=lab-a

kubectl label node k3d-labs-affinity-agent-0 topology.kubernetes.io/zone=lab-a

kubectl label node k3d-labs-affinity-agent-1 topology.kubernetes.io/zone=lab-b
```

> Now all nodes are in the `lab` region; the control plane and agent-0 are both in zone `lab-a`; agent-1 is in zone `lab-b`.

## Pod affinity & anti-affinity

You use node topology in Pod affinity rules - expressing that Pods should run on nodes where other Pods are running (or not running).

Start by deleting the whoami Deployment so we have a fresh set of Pods to work with:

```
kubectl delete deploy whoami 
```

The new spec in [colocate-region/deployment.yaml](./specs/whoami/colocate-region/deployment.yaml) has two affinity rules:

- node affinity to prevent Pods running on control plane nodes
- Pod affinity to require all Pods to run on nodes in the same region

Pod affinity uses the topology key to state the level where the grouping happens - we could use our cluster labels to put all Pods in the same region, zone or node.

```
kubectl apply -f labs/affinity/specs/whoami/colocate-region

kubectl get po -l app=whoami -o wide
```

> Pods will be scheduled on both agent nodes, which are both in the same region

Zones are used to define different failure areas within a region - each zone may have dedicated power and networking, so if one zone fails the servers in another zone keep running. 

In a cluster with zones you may want to ensure Pods run on nodes in different zones, for high availability. You do that with anti-affinity:

- [spread-zone/deployment.yaml](./specs/whoami/spread-zone/deployment.yaml) - removes the node affinity so Pods can run on the control plane; uses Pod affinity to keep Pods all in one region and Pod anti-affinity to keep Pods away from other Pods in the same zone.

Clear down the existing Deployment and create the new one:

```
kubectl delete deploy whoami 

kubectl apply -f labs/affinity/specs/whoami/spread-zone
```

📋 How many Pods are running? Which nodes are they on?

<details>
  <summary>Not sure?</summary>

```
kubectl get po -l app=whoami,update=spread-zone -o wide
```

You'll see two Pods running, one on agent-1 and the other on agent-0 or the server. The rest will all stay as Pending, and if you describe a Pending Pod you'll see there are no available nodes which match the affinity rules.

These are _required_ affinity rules, and they state Pods shouldn't run on a node if there's another Pod from this Deployment already running on a node in the same zone.

So when a Pod is running on agent-1, no more Pods will be scheduled for nodes in zone lab-b; and when a Pod is running on agent-0 or the server, no more Pods will be scheduled for zone lab-a. 

</details><br/>

This is probably not what you want. The rule might instead be: _all Pods **must** run in the same region, and within the region Pods **should** be spread across zones - but it's OK to run multiple Pods in the same zone_. This spec does expresses that rule:

- [prefer-spread-zone/deployment.yaml](./specs/whoami/prefer-spread-zone/deployment.yaml) - has a required affinity rule at the region level, and a preferred rule at the zone level

Replace the Deployment with this spec:

```
kubectl delete deploy whoami

kubectl apply -f labs/affinity/specs/whoami/prefer-spread-zone
```

Now you should find all six replicas running, with at least one Pod on each node (_but this rule is a soft preference so you may find all Pods on one node_):

```
kubectl get po -l app=whoami,update=prefer-spread-zone -o wide
```

## Lab

Preferred affinity rules have a weighting, so you can express the priority of your preferences.

For this lab we want to use that to express affinity rules for the whoami app - create a new Deployment spec configured so that:

- Pods only run on worker nodes which have a `cis-compliance` label applied 

- Pods prefer to run on nodes labelled with `cis-compliance=verified`

- But Pods can run on nodes labelled with `cis-compliance=in-progress`

Start by deleting the existing Deployment so you don't have to wrestle with a rollout:

```
kubectl delete deploy whoami 
```

You'll need to flag that agent-0 is in the process of getting CIS compliance, so Pods can run on it. Can you configure your Deployment to run five Pods on agent-1 - which is CIS verified - and only one on agent-0?

> Stuck? Try [hints](hints.md) or check the [solution](solution.md).

___

## **EXTRA** Node affinity for multi-arch images

<details>
  <summary>Working with multi-platform clusters</summary>

Docker images can be published with multi-architecture support, so one image tag actually has several variants which work on different CPU architectures or operating systems.

This example is a simple web server which can run on Linux servers using Intel or Arm, or Windows servers on Intel: [diamol/ch02-hello-diamol-web](https://hub.docker.com/r/diamol/ch02-hello-diamol-web/tags).

You can check the OS and CPU architecture for your nodes:

```
kubectl get nodes -L kubernetes.io/os -L kubernetes.io/arch
```

> Yours will (probably) all be Linux on amd64 (Intel) - but a Kubernetes cluster can contain a mix of platforms.

You can use affinity rules to get the most out of your cluster if you have multi-arch images. Maybe your production cluster has 20 Linux nodes and 5 Windows nodes. The Windows nodes are mainly for legacy apps - but you want to use their capacity too.

- [multi-arch/linux-or-windows.yaml](./specs/multi-arch/linux-or-windows.yaml) expresses that requirement: Pods must run on (Linux or Windows)nodes, but with a 10-1 preference for Linux, so they're will only be Pods on the Windows nodes if the Linux nodes are full

📋 Why are there so many affinity rules in the spec?

<details>
  <summary>Not sure?</summary>

The OS and architecture labels are standard for all Kubernetes clusters, but the name of the labels has changed:

- older versions used `beta.kubernetes.io/os` and `beta.kubernetes.io/arch`
- newer versions use `kubernetes.io/os` and `kubernetes.io/arch`

The rules use both so the same spec can be used on old and new clusters.

</details><br/>

Your cluster is Linux-only, but you should still get all the Pods running:

```
kubectl delete deploy whoami 

kubectl apply -f labs/affinity/specs/multi-arch

kubectl get po -o wide -l app=hello-web
```

> You'll see Pods on the server and both agents - there are no affinity rules for node roles

## Cleanup

If you want to continue using your k3d cluster, clean up the lab resources:

```
kubectl delete svc,deploy -l kubernetes.courselabs.co=affinity
```

**OR** remove your k3d cluster and switch back to your previous cluster (e.g. Docker Desktop):

```
k3d cluster delete labs-affinity

kubectl config use-context docker-desktop

# use this to find your previous context if you don't know the name:
kubectl config get-contexts
```