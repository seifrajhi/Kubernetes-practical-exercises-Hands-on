## Exercise 14

Create a simple template for the pod:
```
kubectl run plumpod --image=busybox:1.31.0 -n plum --dry-run=client -o yaml > plumpod.yaml
```

Edit the yaml to include the readiness probe:
```
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: plumpod
  name: plumpod
  namespace: plum
spec:
  containers:
  - image: busybox:1.31.0
    name: plumpod
    resources: {}
    readinessProbe:
      exec:
        command:
        - cat
        - /tmp/plumpplum
      initialDelaySeconds: 3
      periodSeconds: 6
  dnsPolicy: ClusterFirst
  restartPolicy: Always
status: {}

```

Apply the changes:
```
kubectl create -f plumpod.yaml
```
