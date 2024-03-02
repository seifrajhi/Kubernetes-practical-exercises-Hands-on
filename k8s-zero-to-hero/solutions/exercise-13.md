## Exercise 13

Create a simple template for the deployment:
```
kubectl create deployment banana-peel --image=nginx:1.9.1 --replicas=2 -n banana --dry-run=client -o yaml > banana-peel-deploy.yaml

```
Add the yaml to include the service account:
```
apiVersion: apps/v1
kind: Deployment
metadata:
  creationTimestamp: null
  labels:
    app: banana-peel
  name: banana-peel
  namespace: banana
spec:
  replicas: 2
  selector:
    matchLabels:
      app: banana-peel
  strategy: {}
  template:
    metadata:
      creationTimestamp: null
      labels:
        app: banana-peel
    spec:
      serviceAccountName: mega-banana-v5
      containers:
      - image: nginx:1.9.1
        name: nginx
```

Apply the yaml:
```
kubectl create -f banana-peel-deploy.yaml
```
