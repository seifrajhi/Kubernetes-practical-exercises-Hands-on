# Kubernetes Hands-On Labs

Before you can do these labs, you will need a Kubernetes cluster. 

The easies way is to provision a k3s cluster on docker, called "[k3d](https://github.com/rancher/k3d)":

```
> k3d create --name "k3d-cluster" --publish "80:80" --workers 2
> export KUBECONFIG="$(k3d get-kubeconfig --name='k3d-cluster')"
```

Verify:

```
> kubectl get nodes
NAME                       STATUS   ROLES    AGE   VERSION
k3d-k3d-cluster-worker-0   Ready    <none>   90s   v1.17.2+k3s1
k3d-k3d-cluster-server     Ready    master   89s   v1.17.2+k3s1
k3d-k3d-cluster-worker-1   Ready    <none>   89s   v1.17.2+k3s1
```

