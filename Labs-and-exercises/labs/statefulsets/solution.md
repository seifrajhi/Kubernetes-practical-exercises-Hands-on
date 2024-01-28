# Lab Solution

You need to define a StatefulSet - the spec is very similar to the Deployment, but you need a Service and you'll replace the emptyDir volume with a mount and a volumeClaimTemplate:

- [solution/service.yaml](solution/service.yaml) - headless Service for the StatefulSet
- [solution/statefulset.yaml](solution/statefulset.yaml) - StatefulSet with PVC template and parallel management policy

You'll need to remove your Deployment before you create the StatefulSet:

```
kubectl delete deploy simple-proxy

kubectl apply -f labs/statefulsets/solution
```

Watch the Pods - these are created in parallel:

```
kubectl get po -l app=simple-proxy --watch

# Ctrl-C when the Pods are running

kubectl get pvc -l app=simple-proxy
```

> Each Pod has a PVC, which is mounted into the `/cache` folder

Try the proxy:

```
curl -v localhost:8040

# OR 
curl -v localhost:30040
```

> Repeat and you'll see `X-Cache: HIT` in the response headers

The cache is in the volume for each Pod:

```
kubectl exec simple-proxy-0 -- ls /cache

kubectl exec simple-proxy-1 -- ls /cache
```

> Back to the [exercises](README.md).