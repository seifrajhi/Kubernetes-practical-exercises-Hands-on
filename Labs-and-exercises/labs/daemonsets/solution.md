# Lab Solution

DaemonSets let you specify the update strategy, and Kubectl supports deletes for controllers without deleting Pods.

## Replace the Pod only when it's manually deleted

- [daemonset-update-on-delete.yaml](solution/daemonset-update-on-delete.yaml) - specifies an update strategy type of OnDelete

The DaemonSet wil only create a replacement Pod when the existing one gets deleted by another process:

```
kubectl apply -f labs/daemonsets/solution

kubectl get pods -l app=nginx --watch
```

The DaemonSet has been updated, but it won't replace the Pod **even though the Pod spec has changed**.

Trigger the update by deleting the Pod:

```
kubectl delete pod -l app=nginx

kubectl get pods -l app=nginx
```

## Delete the DaemonSet but retain the Pod

Kubernetes maintains the relationship between Pods and controllers, but it lets you break that relationship with non-cascading deletes. 

```
kubectl delete ds nginx --cascade=false

kubectl get ds

kubectl get po -l app=nginx
```

The DaemonSet is removed, but the Pod which it used to control is still there.

> Back to the [exercises](README.md).