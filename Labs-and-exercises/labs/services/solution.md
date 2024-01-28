# Lab Solution

You can list the all the Pods for a Service using:

```
kubectl describe svc whoami

# OR
kubectl get endpoints whoami
```

> Endpoints are Kubernetes objects, but they're usually managed by Services and you don't create them yourself

## Services with no endpoints

You can create a Service with no matching Pods by adding a label:

- [whoami-svc-zeromatches.yaml](solution/whoami-svc-zeromatches.yaml)

There are no Pods which match because the whoami Pod doesn't have a `version` label:

```
kubectl apply -f labs/services/solution/whoami-svc-zeromatches.yaml

kubectl get endpoints whoami-zero-matches

kubectl exec sleep -- nslookup whoami-zero-matches

kubectl exec sleep -- curl -v -m 5 http://whoami-zero-matches
```

> There's an IP address for the Service but no endpoints, so the curl call times out


## Services with multiple endpoints

Many Pods can run with the same labels. Deploy a second whoami Pod with the same spec as the first - only the name needs to change:

```
kubectl apply -f labs/services/solution/whoami-pod-2.yaml

kubectl get po -o wide -l app=whoami

kubectl get endpoints whoami
```

> Both Pod IP addresses are registered as Service endpoints

```
kubectl exec sleep -- curl -v http://whoami
```

> The IP in the response is the Pod IP, the requested IP is the Service. Repeat the call and the Pod IP in the response changes - the Service load-balances requests between Pods.

> Back to the [exercises](README.md).