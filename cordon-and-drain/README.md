- Cordon will mark the node as unschedulable.

- Uncordon will mark the node as schedulable.

- Once you cordon the given node, it will be marked as unschedulable to prevent new pods from scheduling.

- We cannot schedule a new pod until the node is cordoned.

- You can use `kubectl drain` to safely evict all of your pods from a node before you perform maintenance on the node (e.g. kernel upgrade, hardware maintenance, etc.).

-  Safe evictions allow the pod's containers to gracefully terminate.


First, identify the name of the node you wish to drain. You can list all of the nodes in your cluster with:

```
kubectl get nodes
```

Next, tell Kubernetes to drain the node:

```
kubectl drain <node name>
```

Next, mark the node to not schedule new pods.

```
kubectl cordon <node name>
```

Once maintenance period is over, uncordon the node to schedule new pods.

```
kubectl uncordon <node name>
```

