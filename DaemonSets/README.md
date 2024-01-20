A _DaemonSet_ ensures that all (or some) Nodes run a copy of a Pod. 

As nodes are added to the cluster, Pods are added to them. 

As nodes are removed from the cluster, those Pods are garbage collected. Deleting a DaemonSet will clean up the Pods it created.

Some typical uses of a DaemonSet are:

- running a cluster storage daemon on every node
- running a logs collection daemon on every node
- running a node monitoring daemon on every node


## Create a daemonset:

```
kubectl create -f daemonset.yaml
```

## Check the pod running:

```
kubectl get pods -n kube-system
```

## List out the daemonsets

```
kubectl get ds -o wide
```

## Edit a daemonset:

```
kubectl edit daemonset fluentd
```
## Delete a daemonset:

```
kubectl delete daemonset fluentd
```

### Reference link : https://medium.com/avmconsulting-blog/deploying-daemonsets-service-in-kubernetes-k8s-37d642dcd66f