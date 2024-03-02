## Exercise 10

```
apiVersion: v1
kind: Pod
metadata:
  creationTimestamp: null
  labels:
    run: nginx
  name: nginx
spec:
  securityContext:
    runAsUser: 1000
    runAsGroup: 2000
  containers:
  - image: nginx:1.7.9
    name: nginx
    resources: {}
    securityContext:
      allowPrivilegeEscalation: false
```
