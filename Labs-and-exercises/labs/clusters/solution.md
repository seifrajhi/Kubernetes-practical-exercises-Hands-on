# Lab Solution

First check to see where the Pods are running:

```
kubectl get po -l app=whoami -o wide
```

Now use the `cordon` command to mark the agent-1 node as unschedulable, so no new Pods will be allocated to it:

```
kubectl cordon k3d-lab-clusters-agent-1
```

Drain the node to remove all Pods, using the flag to ignore the Pods which are managed by DaemonSets (otherwise those Pods would not be removed):

```
kubectl drain k3d-lab-clusters-agent-1 --ignore-daemonsets --delete-emptydir-data
```

Check the Pod list now and you'll see the agent-1 Pods are terminated, and replacements get created; check the node list and you'll see the status of the cordoned node:

```
kubectl get po -l app=whoami -o wide

kubectl get nodes -o wide
```

When the work is finished on the server, it can be made available for scheduling again:

```
kubectl uncordon k3d-lab-clusters-agent-1
```

Bringing a node online again doesn't cause Pods to be redistributed - agent-1 is available again but it won't run any whoami Pods unless you restart the rollout so new Pods are scheduled:

```
kubectl rollout restart deploy whoami 

kubectl get po -l app=whoami -o wide
```