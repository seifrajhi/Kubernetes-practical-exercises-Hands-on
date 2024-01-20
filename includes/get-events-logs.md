```
kx
```

```
kn
```

```
k delete all --all # with caution!!!
```

```
k apply -f 0-nginx-all.yaml
```

```
k get all
```


# where is the ingress?


```
k get ingress # ingress objects are not namespaced
```

```
k get events
```

```
k get events -A
```

```
k get events --sort-by=.metadata.creationTimestamp # List Events sorted by timestamp
```

```
k get events -n <namespace name>
```

```
k logs nginx-<press tab>
```

```
k describe pod nginx-<press tab>
```

```
k describe deployment nginx
```

```
k describe replicasets nginx-<press tab>
```

```
k get services --sort-by=.metadata.name # List Services Sorted by Name
```

```
k get pods --sort-by=.metadata.name
```

```
k get endpoints
```

```
k explain pods,svc
```

```
k get pods -A # --all-namespaces
```

```
k get nodes -o jsonpath='{.items[*].spec.podCIDR}'
```

```
k get pods -o wide
```
```
k get pod my-pod -o yaml --export > my-pod.yaml # Get a pod's YAML without cluster 
specific information
```

```
k get pods --show-labels # Show labels for all pods (or other objects)
```

```
k get pods --sort-by='.status.containerStatuses[0].restartCount'
```

```
k cluster-info
```

```
k api-resources
```

```
k api-resources -o wide
```

```
kubectl api-resources --verbs=list,get # All resources that support the "list" and "get"
request verbs
```

```
k get apiservice
```

