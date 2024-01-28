# Securing Traffic with Network Policies

Networking in Kubernetes is flat - Pods and Services have cluster-wide IP addresses and can communicate across different namespaces and nodes. 

That makes it easy to model distributed applications, but it means you can't have segregated networks within the cluster or stop applications in Pods reaching outside of the cluster.

Those are security gaps which the Network Policy API fills, allowing you to model network access as part of your application deployment. The API is straightforward but Kubernetes has a plugin model for its networking component and not all network plugins apply policies.

## Reference

- [NetworkPolicy API spec](https://v1-18.docs.kubernetes.io/docs/reference/generated/kubernetes-api/v1.18/#networkpolicy-v1-networking-k8s-io)
- [Network plugins (CNI)](https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/)
- [Common NetworkPolicy recipes](https://github.com/ahmetb/kubernetes-network-policy-recipes)
- [Creating a k3d cluster with Calico CNI](https://k3d.io/usage/guides/calico/)

## Deploy the APOD application

Let's start by deploying a simple distributed app. Nothing special in the specs - just Deployments and Services:

- [apod/api.yaml](./specs/apod/api.yaml) - a REST API which provides information about NASA's daily astronomy picture; used internally by the web app

- [apod/log.yaml](./specs/apod/log.yaml) - a REST API which logs information about users of the app; used internally by the web app

- [apod/web.yaml](./specs/apod/web.yaml) - web application which consumes the REST APIs and shows the picture of the day; published with a NodePort Service

_Create the resources:_

```
kubectl apply -f labs/networkpolicy/specs/apod
```

> Wait for all the Pods to be ready then browse to http://localhost:30016, you should see the working app

Now we'll enforce a deny-all network policy:

- [deny-all/default-deny.yaml](./specs/deny-all/default-deny.yaml) - the selector is empty so this will be enforced for all Pods

📋 This will stop all network traffic to and from all Pods. Why?

<details>
  <summary>Not sure?</summary>

Policy rules are additive - like RBAC - so subjects start with no permissions. 

There are no ingress or egress permissions in the rules, so this is a policy which allows nothing - effectively blocks all outgoing and incoming communication to all Pods.

</details><br />

_Apply the deny-all policy:_

```
kubectl apply -f labs/networkpolicy/specs/deny-all

kubectl get netpol
```

This **should** block traffic, so the web app can't communicate with the APIs. But your Kubernetes cluster probably doesn't enforce network policy, so the policy gets created but not applied.

> Refresh http://localhost:30016 the app (probably) still works

We'll switch to a new cluster and build it with a network provider which does enforce policy. 

_Remove the existing app to free up resources:_

```
kubectl delete  -f labs/networkpolicy/specs/apod
```

** If you're using K3d already, stop your cluster so we don't get a port collision:**

```
k3d cluster stop k8s
```

## Install k3d CLI

[k3d](https://k3d.io) is a tool for creating local Kubernetes clusters, where each node runs inside a Docker container. It's not as user-friendly as Docker Desktop, but it does give you advanced options for configuring your cluster.

- Use the install instructions https://k3d.io/v5.0.0/#installation **OR**

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

_k3d requires Docker - Docker Engine on Linux or Docker Desktop on Mac/Windows, so you can't use it with any other container runtime._

## Try a new cluster with NetworkPolicy support

You can create simple clusters with k3d to represent different environments or projects, then start and stop them when you need to. [k3d cluster create](https://k3d.io/v5.0.0/usage/commands/k3d_cluster_create/) has lots of options.

k3d clusters use the Flannel CNI plugin by default (like most clusters), but you can configure a new cluster with no network plugin at all.

_Create a new cluster with no networking:_

```
k3d cluster create labs-netpol -p "30000-30040:30000-30040@server:0" --k3s-arg '--flannel-backend=none@server:0' --k3s-arg '--disable=servicelb@server:0' --k3s-arg '--disable=traefik@server:0' --k3s-arg '--disable=metrics-server@server:0'
```

- this creates a single-node cluster without the Flannel CNI installed
- ports are published to the local machine, so you can use localhost with NodePort Services
- extra k3d features like LoadBalancer support and metrics are turned off

> k3d will change your Kubectl context to point to the new cluster

You should have one node in the cluster - it's actually a Docker container:

```
docker ps
```

📋 Check the status of your new cluster. Is it ready to run apps now?

<details>
  <summary>Not sure?</summary>

The cluster isn't ready:

```
kubectl get nodes
```

The node is in the _NotReady_ state, because there's no network installed.

Dig a bit deeper and you'll see the DNS server isn't running:

```
kubectl get deploy -n kube-system
```

DNS requires a network plugin.

</details><br />

[Calico](https://docs.projectcalico.org/getting-started/kubernetes/) is a network plugin which supports NetworkPolicy. It's open-source and very commonly used where network policy is required.

The network plugin runs as a DaemonSet, but it also uses privileged init containers to modify the network configuration of OS on the node. That's why we're using k3d, so we don't impact the networking on your main cluster:

- [k3d/calico.yaml](./specs/k3d/calico.yaml) - is from the Calico docs, it includes the network plugin and RBAC rules

_Install Calico and wait for the Pods to become ready:_

```
kubectl apply -f labs/networkpolicy/specs/k3d

kubectl get pods -n kube-system --watch
```

> You'll see various Calico Pods starting up in the `kube-system` namespace

📋 Is the cluster ready now?

<details>
  <summary>Not sure?</summary>

```
kubectl get nodes
```

Your node should be ready now, and the `coredns` Deployment should be up to scale.

</details><br />

Now we have a network-policy enforcing cluster, we can try the APOD app again:

```
kubectl apply -f labs/networkpolicy/specs/apod
```

> This runs the same app on the new cluster. When the Pods are running browse to http://localhost:30016 and check it all works

Apply the same deny-all policy:

```
kubectl apply -f labs/networkpolicy/specs/deny-all

kubectl get netpol
```

> Calico will enforce this policy. Refresh http://localhost:30016, the app times out
 
There is no egress policy allowing communication from the web app to the API **or even to the DNS server**.

```
# this will fail with a bad address message: 
kubectl exec deploy/apod-web -- wget -O- http://apod-api/image
```

📋 Check this is not just a DNS issue by finding the IP address of the API Pod and calling it with an exec from the web Pod.

<details>
  <summary>Not sure how?</summary>

Print the IP address with a wide Pod list:

```
kubectl get po -l app=apod-api -o wide
```

Now you can use the IP address in the command:

```
# this will fail with a timeout
kubectl exec deploy/apod-web -- wget -O- -T2 http://<pod-ip-address>/image
```

</details><br />

## Deploy policies for application components

You'll often see a default deny-all policy, to prevent any accidental network communication. In that case you need to explicitly model all the communication lines between your components:

- [network-policies/apod-log.yaml](./specs/apod/network-policies/apod-log.yaml) - allows ingress from the web Pod to the API port; no egress as this component doesn't make any outgoing calls

- [network-policies/apod-web.yaml](./specs/apod/network-policies/apod-web.yaml) - allows ingress from any location; egress to the two API Pods, and the DNS server (so the app can get the IP addresses of the API Pods)

- [network-policies/apod-api.yaml](./specs/apod/network-policies/apod-api.yaml) - allows ingress from the web Pod; egress to the DNS server and to the IP address ranges where the 3rd-party API is hosted

> If you want to restrict access to IP blocks like this, the services you use need to have static addresses (you can find them using e.g. `dig api.nasa.gov`)

_Apply the new policies:_

```
kubectl apply -f labs/networkpolicy/specs/apod/network-policies

kubectl get netpol
```

_Confirm the web Pod can use the API:_

```
kubectl exec deploy/apod-web -- wget -O- -T2 http://apod-api/image
```

The API fetches data from the NASA APIs:

```
kubectl describe netpol apod-api
```

> Refresh http://localhost:30016 and the app will be working again

## Lab

We've got the APOD app running with a nicely secured network, but the policies are not as tightly controlled as they could be. 

Traffic is allowed based on label selectors, and a malicious user could deploy a Pod with the expected labels and gain access:

- [apod-hack/sleep.yaml](./specs/apod-hack/sleep.yaml) - a basic sleep Pod with the `apod-web` label

Deploy that Pod and you can use it to bypass security and use the API:

```
kubectl apply -f labs/networkpolicy/specs/apod-hack

kubectl exec sleep -- wget -O- http://apod-api/image
```

This can be prevented by deploying the app to a custom namespace, which could be secured with RBAC. Two tasks for you:

- change app to use the `apod` namespace
- change the network policies to restrict ingress traffic to Pods from the `apod` ns

(You'll want to delete the existing APOD app to start with).

> Stuck? Try [hints](hints.md) or check the [solution](solution.md).

___

## Cleanup

**If** you want to reuse your k3d cluster, you can delete all the exercise resources:

```
kubectl delete ns apod

kubectl delete all,netpol -A -l kubernetes.courselabs.co=network-policy
```

**Or** if you want to delete this cluster and switch back to your old one:

```
k3d cluster delete labs-netpol

kubectl config use-context docker-desktop # OR your old cluster name

kubectl delete all,netpol -A -l kubernetes.courselabs.co=network-policy
```

**And** if you were originally using a K3d cluster which you stopped, you'll need to start it again:

```
k3d cluster start k8s
```