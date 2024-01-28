
# Running Replicas on Every Node with DaemonSets

Most Pod controllers let the Kubernetes scheduler work out which node should run a Pod. DaemonSets are different - they run exactly one Pod on every node.

They're for workloads where you want high-availabilty across multiple nodes, but you don't need high levels of scale. Or where the app needs to work with each node, e.g. collecting logs.

Deployments are better suited to most apps and DaemonSets are less common, but you will see them used and they're not complex to work with.

## API specs

- [DaemonSet (apps/v1)](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#daemonset-v1-apps)

<details>
  <summary>YAML overview</summary>

The DaemonSet is a Pod controller, so all the important details go into the Pod spec - which is exactly the same Pod API you use with Deployments:

```
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: nginx
spec:
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      # Pod spec 
```

- `selector` - the labels used to identify Pods owned by the DaemonSet
- `template.metadata` - Pod labels, which must match or be a superset of the selector
- `template.spec` - standard Pod spec

</details><br/>

## Deploy a DaemonSet with a HostPath

One valid use-case for DaemonSets is where the application needs to use resources specific to the node. Multiple Pods running on the node might clash over the resources, so a DaemonSet prevents that.

- [daemonset.yaml](specs/nginx/daemonset.yaml) - defines an Nginx app where logs are written to a HostPath volume, directly using the node's disk
- [services.yaml](specs/nginx/services.yaml) - defines Services to route to the Nginx Pod; the label selector mechanism is the same as with Deployments

```
kubectl apply -f labs/daemonsets/specs/nginx

kubectl get daemonset
```

> The `desired` count matches the number of nodes in your cluster. In a single-node cluster you'll get one Pod; with 10 nodes, 10 Pods

Services route to Pods in the same way, whether they're managed by a DaemonSet or a ReplicaSet. 

📋 Confirm that the Pod IP address is enlisted in the Service.

<details>
  <summary>Not sure how?</summary>

```
kubectl get po -l app=nginx -o wide

kubectl get endpoints nginx-np
```

</details><br />

> Browse to the app at http://localhost:30010 or http://localhost:8010 and you'll see the standard Nginx page

## Updating DaemonSets

DaemonSets run exactly one Pod on each node, so the update behaviour is to remove Pods before starting replacements.

This is different from Deployments, which default to starting new Pods and checking they're healthy before removing old ones. DaemonSet updates can break your app:

- [update-bad/daemonset-bad-command.yaml](specs/nginx/update-bad/daemonset-bad-command.yaml) has a misconfigured command in the Pod container - when the container runs, it will exit instead of running Nginx

```
kubectl apply -f labs/daemonsets/specs/nginx/update-bad

kubectl get pods -l app=nginx --watch
```

> You'll see the old Pod terminates first, then the new Pod starts and fails

Try the app - it's broken. With a Deployment the old Pod would not have been removed until the new Pod was ready, so the app would have stayed online.

## Pods with init containers

The bad update in the last exercise tried to write a new HTML page for Nginx to serve, but changing the command in the app container isn't the way to do it.

All Pods support [init containers](https://kubernetes.io/docs/concepts/workloads/pods/init-containers/) which you can use for startup tasks. An init container can share volumes with the app container, and it will run before the app container starts:

- [daemonset-init-container.yaml](specs/nginx/update-good/daemonset-init-container.yaml) - uses an init container to write a new HTML page for the Nginx app container to serve

Deploy the new update:

```
kubectl apply -f labs/daemonsets/specs/nginx/update-good

kubectl get pods -l app=nginx --watch
```

> You'll see some new statuses in the output, like Init and PodInitializing

The init container runs and completes, and then the app container starts. When the Pod is in the Ready status, only the app container is running.

```
kubectl logs -l app=nginx

kubectl exec daemonset/nginx -- cat /usr/share/nginx/html/index.html
```

> The content of the HTML was written by the init container in the shared EmptyDir volume

Try the app, it's working again and it has a new homepage.

## Deploying to a subset of nodes

DaemonSets run a Pod on every node - the controller watches the node status as well as the Pod status to make sure the desired number of replicas are correct.

You might only want Pods on some of the nodes, and the DaemonSet supports that with a node selector:

- [daemonset-node-selector.yaml](specs/nginx/update-subset/daemonset-node-selector.yaml) - adds a node selector to the DaemonSet, so Pods will only run on nodes which have a matching label

Apply the change - what do you think will happen to the existing Nginx Pod?

```
kubectl apply -f labs/daemonsets/specs/nginx/update-subset

kubectl get pods -l app=nginx --watch
```

> It got deleted. No nodes match the criteria for the DaemonSet so the desired count is 0. The Pod is removed to get to the desired count.

As soon as a node matches the selector, a Pod gets scheduled for it.

📋 Add the missing label to your node and confirm a Pod starts.

<details>
  <summary>Not sure how?</summary>

```
kubectl label node $(kubectl get nodes -o jsonpath='{.items[0].metadata.name}') kubernetes.courselabs.co.ip=public

kubectl get pods -l app=nginx --watch
```

> A new Pod is created, and the app is working again.

</details><br/>

## Lab

There are only a couple more features of DaemonSets - they're rarely used but very useful when you do need them.

First we want a way to manually control when Pods get replaced, so we can update the DaemonSet but the new Pod won't be created until we delete the old one.

Second we want to do the reverse - delete the DaemonSet but leave the Pod intact.

> Stuck? Try [hints](hints.md) or check the [solution](solution.md).

___

## **EXTRA** Deploy a debug Pod to a DaemonSet node

<details>
  <summary>Following Pods with affinity rules</summary>

The Nginx Pod writes logs to a HostPath volume:

```
kubectl exec daemonset/nginx -- ls /var/log/nginx
```

You can deploy another Pod with the same HostPath volume spec, and it will have shared storage with the Nginx Pod. 

In a multi-node cluster you need to ensure the new Pod lands on the same node as the Nginx Pod and you can do that with [Pod affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity):

- [sleep-with-hostPath.yaml](specs/sleep-with-hostPath.yaml) - defines a sleep Pod with a HostPath volume and an affinity rule, which means this Pod will be scheduled on the same node as the Nginx Pod

📋 Deploy the new Pod and verify it lands on the same node.

<details>
  <summary>Not sure how?</summary>

```
kubectl apply -f labs/daemonsets/specs/sleep-with-hostPath.yaml

kubectl get po -l app -o wide
```

</details><br/>

> In a single-node cluster, every Pod will be on that node - but this example works the same way on a multi-node cluster

Now the two Pods share a part of the host node's filesystem:

```
kubectl exec daemonset/nginx -- ls -l /var/log/nginx

kubectl exec pod/sleep -- ls -l /node-root/volumes/nginx-logs
```

Some container images are built `FROM scratch`, which means there is no operating system and no shell to `exec` into. This is one approach to launch a second Pod that can help debug issues with app Pods.

</details><br/>

___

## Cleanup

```
kubectl delete svc,ds,po -l kubernetes.courselabs.co=daemonsets
```